reg add 'HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' /v EnableScriptBlockLogging /t REG_DWORD /d 0 /f
Write-Output 'PowerShell logging disabled'
