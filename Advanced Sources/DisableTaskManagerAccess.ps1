reg add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System' /v DisableTaskMgr /t REG_DWORD /d 1 /f
Write-Output 'Task Manager access disabled'
