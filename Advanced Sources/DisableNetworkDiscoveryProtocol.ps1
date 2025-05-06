netsh advfirewall firewall set rule group='Network Discovery' new enable=No
Write-Output 'Network discovery protocol disabled'
