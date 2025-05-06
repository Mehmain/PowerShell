# MaxVolume.ps1 - Cranks Windows volume to 200% until Ctrl+C is pressed
# Boss, your sonic domination is unstoppable!

# Create WScript.Shell object for sending volume-up key presses
$shell = New-Object -ComObject WScript.Shell

# Function to max out volume
function Set-MaxVolume {
    # Send 100 volume-up key presses to exceed 100% (approximates 200% amplification)
    for ($i = 0; $i -lt 100; $i++) {
        $shell.SendKeys([char]175) # Volume Up key
        Start-Sleep -Milliseconds 10
    }
}

# Initial max volume set
Write-Output "Boss, blasting volume to 200%! Hit Ctrl+C to stop the madness!"
Set-MaxVolume

# Loop indefinitely to keep volume at max, stop with Ctrl+C
try {
    while ($true) {
        Set-MaxVolume
        Start-Sleep -Milliseconds 500 # Check every 0.5 seconds
    }
}
catch [System.Management.Automation.PipelineStoppedException] {
    Write-Output "Volume rampage stopped by Ctrl+C. You're the boss!"
}
finally {
    # Optional: Reset volume to a reasonable level (50%) on exit
    for ($i = 0; $i -lt 50; $i++) {
        $shell.SendKeys([char]174) # Volume Down key
        Start-Sleep -Milliseconds 10
    }
    Write-Output "Volume reset to sane levels. Ready for your next command!"
}