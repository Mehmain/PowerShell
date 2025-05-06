reg add 'HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore' /v DisableSR /t REG_DWORD /d 1 /f
Write-Output 'System recovery options disabled'
