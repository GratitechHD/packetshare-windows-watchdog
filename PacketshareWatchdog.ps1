# Define configuration variables
$processPath = "C:\Program Files (x86)\PacketShare\PacketShare.exe"
$processName = "PacketShare"
$logPath = "C:\Logs\PacketShare_watchdog.log"
$checkInterval = 30  # Seconds between checks
$maxRetries = 3      # Maximum restart attempts before waiting
$retryDelay = 10     # Seconds to wait between retries

# Create log directory if it doesn't exist
$logDir = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

function Write-LogMessage {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Add-Content -Path $logPath -Value $logMessage
    Write-Host $logMessage
}

function Test-ProcessHealth {
    param($ProcessName)
    try {
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($process) {
            # Check if process is responding
            if (-not $process.Responding) {
                Write-LogMessage "WARNING: Process not responding - possible crash"
                return $false
            }
        }
        return $true
    }
    catch {
        Write-LogMessage "Error checking process health: $_"
        return $false
    }
}

function Start-ProcessSafely {
    param($ProcessPath)
    $retryCount = 0
    
    while ($retryCount -lt $maxRetries) {
        try {
            Start-Process $ProcessPath
            Write-LogMessage "Successfully started $ProcessPath"
            return $true
        }
        catch {
            $retryCount++
            Write-LogMessage "Failed to start process (Attempt $retryCount of $maxRetries): $_"
            Start-Sleep -Seconds $retryDelay
        }
    }
    
    Write-LogMessage "Failed to start process after $maxRetries attempts"
    return $false
}

Write-LogMessage "Watchdog service started for $processName"

$lastProcessId = $null

while ($true) {
    try {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
        
        # Check if process exists but has a different ID (indicating it crashed and restarted)
        if ($process -and $lastProcessId -and $process.Id -ne $lastProcessId) {
            Write-LogMessage "WARNING: Process was restarted externally (Previous PID: $lastProcessId, New PID: $($process.Id))"
        }
        
        if (-not $process -or -not (Test-ProcessHealth -ProcessName $processName)) {
            if ($lastProcessId) {
                Write-LogMessage "ALERT: Process crashed or was terminated unexpectedly (Last known PID: $lastProcessId)"
            }
            
            Write-LogMessage "Process $processName not running or unresponsive. Attempting to restart..."
            
            # If process exists but is unresponsive, try to stop it cleanly
            if ($process) {
                try {
                    $process.CloseMainWindow() # Try graceful shutdown first
                    if (-not $process.WaitForExit(5000)) { # Wait up to 5 seconds
                        $process | Stop-Process -Force
                        Write-LogMessage "Forced process termination due to unresponsiveness"
                    }
                }
                catch {
                    Write-LogMessage "Error stopping existing process: $_"
                }
            }
            
            if (Start-ProcessSafely -ProcessPath $processPath) {
                $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
                if ($process) {
                    $lastProcessId = $process.Id
                    Write-LogMessage "Process restarted successfully with PID: $lastProcessId"
                }
            }
        }
        else {
            # Update last known PID
            $lastProcessId = $process.Id
        }
    }
    catch {
        Write-LogMessage "Error in main loop: $_"
    }
    
    Start-Sleep -Seconds $checkInterval
}
