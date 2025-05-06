reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System' /v EnableLUA /t REG_DWORD /d 0 /f
Write-Output 'User Account Control disabled'
