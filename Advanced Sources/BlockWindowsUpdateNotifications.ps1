reg add 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate' /v SetDisableUXWUAccess /t REG_DWORD /d 1 /f
Write-Output 'Windows update notifications blocked'
