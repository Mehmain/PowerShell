reg add 'HKLM\Software\Policies\Microsoft\Windows\Backup' /v DisableBackup /t REG_DWORD /d 1 /f
Write-Output 'Windows backup system disabled'
