function Start-CDChaos {
    try {
        $wmplayer = New-Object -ComObject WMPlayer.OCX.7
        $cd = $wmplayer.cdromCollection.Item(0)
        
        if ($null -eq $cd) {
            Write-Host "No CD drive found Time to dig out that old PC from the attic!"
            return
        }
        
        Write-Host "CD Tray Press Ctrl+C to stop"
        
        while ($true) {
            $cd.Eject()
            Write-Host "Tray opened."
            Start-Sleep -Milliseconds (Get-Random -Minimum 1000 -Maximum 3000) # Random delay 1-3 seconds
            
            $cd.Eject() # Eject again to toggle state
            Write-Host "Tray closed."
            Start-Sleep -Milliseconds (Get-Random -Minimum 1000 -Maximum 3000) # Random delay 1-3 seconds
        }
    }
    catch {
        Write-Host "Error controlling CD tray: $_ 😕 Check if a CD drive exists or try running as admin."
    }
    finally {

        if ($wmplayer) {
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wmplayer) | Out-Null
        }
    }
}

Start-CDChaos