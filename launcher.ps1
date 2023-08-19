param([switch]$Elevated)

# What is this?
# It's a script that makes launching TFGhost more stable, smooth as butter
# Bonus: Makes your performance increase by disabling CPU0 from the process affinity list

# Configuration
$ghostExecName = "TFGhost" # TFGhost's executable name **WITHOUT THE .exe** (mine is TFGHOST.exe, yours can be tf2_vac_bypass.exe... and Etc)
$ghostPath = "C:\Users\User\OneDrive\Desktop\Cheats" # Path to the folder with the TFGhost executable inside

# Advanced configuration
$waitTimeBeforeGameOpens = 15 # How much time the program needs to wait until the game automatically opens, increase this if it has no time to set process affinity

# Correct ghostExecName not to have '.exe' in the end, just in case
if ($ghostExecName -like "*.exe") {
    $ghostExecName = $ghostExecName.Substring(0, $ghostExecName.Length - 4)

    Write-Host "'ghostExecName' had '.exe' in the end, corrected it for you..."
}

# Check if the paths specified in configuration actually exist
if (Test-Path -Path $ghostPath -PathType Container) {
    Write-Host "Path '$ghostPath' exists."

    # Construct the full executable path
    $executablePath = Join-Path -Path $ghostPath -ChildPath "$ghostExecName.exe"

    # Check if the executable file exists
    if (Test-Path -Path $executablePath -PathType Leaf) {
        Write-Host "Executable '$ghostExecName.exe' exists in '$ghostPath'."
    } else {
        Write-Output "Executable '$ghostExecName.exe' does not exist in '$ghostPath', please check the configuration settings."
        $closeWindow = $true
    }
} else {
    Write-Output "Path '$ghostPath' does not exist, please check the configuration settings."
    $closeWindow = $true
}

# Close the PowerShell window if the flag is set to true
if ($closeWindow) {
    Start-Sleep -Seconds 5
    Stop-Process -Id $PID
}

# Administrator is elevated function
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Actually check if the privelege is correct
if ((Test-Admin) -eq $false) {
    if ($elevated) {
        # Tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }

    exit
}

# Kill every needed process
$processesToKill = @("hl2", "steam", "steamservice", "steamwebhelper")

# Add TFGhost to list
$processesToKill += $ghostExecName

foreach ($processName in $processesToKill) {
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($process -eq $null) {
        Write-Host "Process '$processName' is not running."
    } else {
        Stop-Process -Name $processName -Force
        Write-Host "Process '$processName' has been terminated."
    }
}

# Wait for them to fully die
Start-Sleep -Seconds 1;

# Start TF2 Ghost
$executablePath = Join-Path -Path $ghostPath -ChildPath "$ghostExecName.exe"
Start-Process -FilePath $executablePath

# Wait for Steam login and Game, 15 seconds should be an ideal time amount
Start-Sleep -Seconds $waitTimeBeforeGameOpens;

# Define the process name or ID
$processName = "hl2"  # Common for most Source games, Team Fortress 2 uses it

# Get the process object
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process -eq $null) {
    Write-Host "Process '$processName' not found."
} else {
    # Get the total number of threads (logical processors)
    $totalThreads = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors

    # Calculate the affinity mask with all threads except thread 0
    $affinityMask = [Math]::Pow(2, $totalThreads) - 2

    # Set the process affinity
    $process.ProcessorAffinity = [IntPtr]::new($affinityMask)
    $process.Refresh()

    Write-Host "Affinity for process '$processName' set to all threads except thread 0."
}

# Congratulations
Write-Host "Success! You can close out of this window now."
