<#
.SYNOPSIS
    Powershell script meant to install all required tools for development on Windows.
    Displays installation progress using Write-Progress.

.DESCRIPTION
    This script defines a set of reusable functions to check for the presence of a CLI tool
    and execute a given installation script block if the tool is missing.

    NOTE: This script MUST be run from an elevated (Administrator) PowerShell session.
    TODO: Maybe a version to report

.NOTES
    Author: Gemini
    Date: October 26, 2025
#>


# ------------------------------------------------------------------------------
#   SCRIPT PARAMETERS  
# ------------------------------------------------------------------------------
[CmdletBinding()]
Param()


# ------------------------------------------------------------------------------
#   ENUMERATION
# ------------------------------------------------------------------------------
# Define an enumeration for tool installation status, replacing the string literals.
enum ToolStatus {
    Pending
    AlreadyPresent
    Installed
    Failed
}


# ------------------------------------------------------------------------------
#   SCRIPT PARAMETERS  
# ------------------------------------------------------------------------------
class ToolInstall {
  [string]$Name
  [string]$Version
  [ToolStatus]$Status
}


# ------------------------------------------------------------------------------
#   FUNCTIONS
# ------------------------------------------------------------------------------
# Checks if a command-line tool is available in the current environment path.
# Returns $true if the command is found, $false otherwise.
function Test-CliToolAvailability {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    # Get-Command will throw an error if the command is not found; 
    # -ErrorAction SilentlyContinue suppresses this.
    return (Get-Command $Command -ErrorAction SilentlyContinue) -ne $null
}


function Install-ToolIfMissing {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [Parameter(Mandatory=$true)]
        [string]$Script
    )

    $tool = [ToolInstall]::new()
    $tool.Name = $Name
    
    # Define a unique ID for the progress bar used inside this function (if we wanted a nested bar)
    $activityId = 100 

    Write-Progress -Activity "Tool: $Name" -Status "Checking if already installed..." -PercentComplete 0 -Id $activityId
    
    # 1. Check if the tool is already installed
    if (Test-CliToolAvailability -Command $Command) {
        Write-Progress -Activity "Tool: $Name" -Status "$Name found. Retrieving version ..." -PercentComplete 90 -Id $activityId
        try {
            $tool.Version = & $Command --version 2>&1
            Write-Progress -Activity "Tool $Name" -Status "Version found: $($tool.Version)" -PercentComplete 100 -Id $activityId -Completed 
        }catch{
            $tool.Version = "Undefined"
            Write-Progress -Activity "Tool: $Name" -Status "Version not found" -PercentComplete 100 -Id $activityId -Completed 
        }
        $tool.Status = [ToolStatus]::AlreadyPresent
        return $tool
    }

    Write-Progress -Activity "Tool: $Name" -Status "Executing installation script..." -PercentComplete 50 -Id $activityId

    # 2. Execute the installation script block
    try {
        Invoke-Expression $Script

        Write-Progress -Activity "Tool: $Name" -Status "Verifying installation..." -PercentComplete 80 -Id $activityId
        
        if (Test-CliToolAvailability -Command $Command) {
            Write-Progress -Activity "Tool: $Name" -Status "✅ Verification successful. " -PercentComplete 100 -Id $activityId -Completed
            $tool.Status = [ToolStatus]::Installed
            return $tool
        } else {
            Write-Progress -Activity "Tool: $Name" -Status "❌ Verification failed. Tool not found in path." -PercentComplete 100 -Id $activityId -Completed
            $tool.Status = [ToolStatus]::Failed
            return $tool
        }

    } catch {
        # Installation failed due to error
        Write-Progress -Activity "Tool: $Name" -Status "❌ An exception occurred during installation" -PercentComplete 100 -Id $activityId -Completed
        Write-Error "Error during $Name installation: $($_.Exception.Message)"
        $tool.Status = [ToolStatus]::Failed
        return $tool
    }
    
    # Ensure progress bar is removed if it somehow wasn't completed in the logic above
    Write-Progress -Activity "Tool: $ToolName" -Status "Cleaning up..." -PercentComplete 100 -Id $activityId -Completed
    $tool.Status = [ToolStatus]::Failed
    return $tool
}


# ------------------------------------------------------------------------------
#   MAIN EXECUTION
# ------------------------------------------------------------------------------
# 1. Define custom installation steps for Chocolatey (and other potential tools)
$chocoInstallationScript = @'
    # Set Execution Policy to Bypass for the current PowerShell process only.
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    
    # Ensure Tls1.2 (or higher) is available, which is required for secure download.
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; # Tls1.2
    
    # Download and execute the official Chocolatey install script.
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
'@

# Define the list of tools to install, using the enum for initial status
$tools = @(
    @{ Name = 'chocolatey'; Command = 'choco'; Script = $chocoInstallationScript; }
)

$currentToolIndex = 0
$progressId       = 1 # ID for the main progress bar
$statusLine       = ""

Write-Host "--------------------------------------------------------------------------------"
Write-Host " ⚒️ SETUP: Development Environment for Windows"
Write-Host "--------------------------------------------------------------------------------"

# Loop through all tools and install if missing
for ($i = 0; $i -lt $tools.Count; $i++) {

    $tool = $tools[$i]
    
    # Update the main progress bar before starting the tool
    Write-Progress -Activity "Installing tools" `
                   -Status "$($tool.Name) (Step $i of $($tools.Count))" `
                   -PercentComplete ($i / $tools.Count * 100) `
                   -Id $progressId
    
    # Call the installation function and capture the result status (as an enum value)
    $result = Install-ToolIfMissing -Name $tool.Name -Command $tool.Command -Script $tool.Script
    
    # Update the main progress bar with the final status for the just-completed tool
    Write-Progress -Activity "Installing tools" `
                   -Status "$($tool.Name) (Step $i of $($tools.Count))" `
                   -PercentComplete ($i / $tools.Count * 100) `
                   -Id $progressId

    $prefix = switch ($result.Status) {
        ([ToolStatus]::Installed)      { "🟢" }
        ([ToolStatus]::AlreadyPresent) { "🔵" }
        ([ToolStatus]::Failed)         { "🔴" }
        default                        { "⚫" }
    }
    $suffix = switch ($result.Status) {
        ([ToolStatus]::Installed)      { "installed " }
        ([ToolStatus]::AlreadyPresent) { "already installed" }
        ([ToolStatus]::Failed)         { "" }
        default                        { "" }
    }

    Write-Host "$prefix $($result.Name) $($result.Version) $suffix"
}

Write-Progress -Activity "Installing Tools" -Status "All checks complete." -Completed -Id $progressId
