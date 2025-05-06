reg add 'HKLM\Software\Policies\Microsoft\Windows NT\SystemRestore' /v DisableSR /t REG_DWORD /d 1 /f
Write-Output 'System restore functionality disabled'
