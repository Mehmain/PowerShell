reg add 'HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore' /v DisableConfig /t REG_DWORD /d 1 /f
Write-Output 'System protection settings disabled'
