reg add 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate' /v DoNotConnectToWindowsUpdateInternetLocations /t REG_DWORD /d 1 /f
Write-Output 'Windows security updates blocked'
