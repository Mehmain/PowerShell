reg add 'HKLM\Software\Microsoft\Windows\Windows Error Reporting' /v Disabled /t REG_DWORD /d 1 /f
Write-Output 'Error reporting system disabled'
