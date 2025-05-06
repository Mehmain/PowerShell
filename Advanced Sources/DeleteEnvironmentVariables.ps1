Remove-Item -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Recurse
Write-Output 'Environment variables deleted'
