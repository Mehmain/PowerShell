reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' /v AUOptions /t REG_DWORD /d 1 /f
Write-Output 'Windows Update service blocked'
