reg add 'HKLM\System\CurrentControlSet\Control\Terminal Server' /v fDenyTSConnections /t REG_DWORD /d 1 /f
Write-Output 'Remote desktop access disabled'
