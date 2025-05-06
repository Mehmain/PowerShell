reg add 'HKCU\Software\Policies\Microsoft\Windows\System' /v DisableCMD /t REG_DWORD /d 2 /f
Write-Output 'Command prompt access disabled'
