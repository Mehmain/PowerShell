Get-NetAdapter | Disable-NetAdapter -Confirm:$false
Write-Output 'All network adapters disabled'
