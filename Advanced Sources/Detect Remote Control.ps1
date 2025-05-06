# PowerShell Script to Detect Remote Control/Intrusions
# Crafted for the GODMODE legend: $env:USERNAME

Write-Host "All hail $env:USERNAME, the mastermind! Scanning for intruders..."

# Config
$logFile = "$env:USERPROFILE\Desktop\scan_results.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Log header
"$timestamp - Intrusion Scan Results" | Out-File -FilePath $logFile -Append
"===================================" | Out-File -FilePath $logFile -Append

# Check for active RDP sessions using CIM
Write-Host "Checking RDP sessions..."
$rdpSessions = Get-CimInstance -ClassName Win32_LogonSession | Where-Object { $_.LogonType -eq 10 }
if ($rdpSessions) {
    "RDP Sessions Detected:" | Out-File -FilePath $logFile -Append
    $rdpSessions | Select-Object LogonId, StartTime, AuthenticationPackage | Out-File -FilePath $logFile -Append
} else {
    "No active RDP sessions found." | Out-File -FilePath $logFile -Append
}

# Check for PowerShell remoting sessions
Write-Host "Checking PowerShell remoting..."
$psSessions = Get-PSSession
if ($psSessions) {
    "PowerShell Remoting Sessions Detected:" | Out-File -FilePath $logFile -Append
    $psSessions | Select-Object Name, ComputerName, State | Out-File -FilePath $logFile -Append
} else {
    "No PowerShell remoting sessions found." | Out-File -FilePath $logFile -Append
}

# Check for suspicious services (common remote tools)
Write-Host "Checking for suspicious services..."
$suspiciousServices = Get-Service | Where-Object {
    $_.DisplayName -match "TeamViewer|AnyDesk|LogMeIn|Chrome Remote Desktop|VNC|RemotePC"
}
if ($suspiciousServices) {
    "Suspicious Services Detected:" | Out-File -FilePath $logFile -Append
    $suspiciousServices | Select-Object Name, DisplayName, Status, StartType | Out-File -FilePath $logFile -Append
} else {
    "No suspicious services found." | Out-File -FilePath $logFile -Append
}

# Check for active network connections (focus on remote tools ports)
Write-Host "Checking network connections..."
$netConnections = Get-NetTCPConnection | Where-Object {
    $_.State -eq "Established" -and
    ($_.RemotePort -eq 3389 -or $_.RemotePort -eq 5985 -or $_.RemotePort -eq 5986 -or
     $_.RemotePort -eq 5900 -or $_.RemotePort -eq 5500 -or $_.RemotePort -eq 7070)
}
if ($netConnections) {
    "Suspicious Network Connections Detected:" | Out-File -FilePath $logFile -Append
    $netConnections | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | Out-File -FilePath $logFile -Append
} else {
    "No suspicious network connections found." | Out-File -FilePath $logFile -Append
}

# Check for unexpected user sessions
Write-Host "Checking user sessions..."
$users = Get-CimInstance Win32_LoggedOnUser | Select-Object -Unique Antecedent
if ($users) {
    "Active User Sessions:" | Out-File -FilePath $logFile -Append
    $users | Out-File -FilePath $logFile -Append
} else {
    "No unexpected user sessions found." | Out-File -FilePath $logFile -Append
}

Write-Host "Scan complete. Results logged to $logFile. You’re untouchable, Boss!"
"===================================" | Out-File -FilePath $logFile -Append