# PowerShell Script to Type into Chrome Search Bar

# Load Windows Forms for SendKeys
Add-Type -AssemblyName System.Windows.Forms

# Function to check if Chrome is running, and start it if not
function Start-Chrome {
    $chromeProcess = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
    if (-not $chromeProcess) {
        Write-Host "[*] Chrome is not running. Starting Chrome..." -ForegroundColor Yellow
        Start-Process "chrome" -ArgumentList "about:blank"
        Start-Sleep -Seconds 3  # Wait for Chrome to start
    } else {
        Write-Host "[*] Chrome is already running." -ForegroundColor Green
    }
}

# Function to bring Chrome to the foreground
function Focus-Chrome {
    $wshell = New-Object -ComObject WScript.Shell
    $chromeWindow = $wshell.AppActivate("Google Chrome")
    if ($chromeWindow) {
        Write-Host "[*] Chrome window focused." -ForegroundColor Green
    } else {
        Write-Host "[!] Failed to focus Chrome window." -ForegroundColor Red
        exit
    }
    Start-Sleep -Milliseconds 500  # Small delay to ensure focus
}

# Function to type into the search bar
function Type-InSearchBar {
    param ($text)
    
    # Select the address bar (Ctrl+L or F6 typically works in Chrome)
    [System.Windows.Forms.SendKeys]::SendWait("^{l}")  # Ctrl+L to focus address bar
    Start-Sleep -Milliseconds 500  # Wait for address bar to be focused

    # Clear the address bar
    [System.Windows.Forms.SendKeys]::SendWait("{BS 100}")  # Backspace to clear
    Start-Sleep -Milliseconds 200

    # Type the text
    Write-Host "[*] Typing '$text' into Chrome search bar..." -ForegroundColor Cyan
    [System.Windows.Forms.SendKeys]::SendWait($text)
    Start-Sleep -Milliseconds 200

    # Press Enter to search
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Write-Host "[*] Search executed." -ForegroundColor Green
}

# Main script
Write-Host "[*] Starting script to type into Chrome search bar..." -ForegroundColor Cyan

# Step 1: Start Chrome if not running
Start-Chrome

# Step 2: Focus Chrome window
Focus-Chrome

# Step 3: Type "im nutting" into the search bar
Type-InSearchBar -text "im nutting"

Write-Host "[*] Done! Check Chrome for the search." -ForegroundColor Cyan