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
#   ELEVATE SCRIPT
# ------------------------------------------------------------------------------
# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}


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


function Add-ProfileLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Line,
        # Defaults to $Profile (Current User, Current Host)
        [string]$Path = $Profile,
        # If set, the profile will be dot-sourced immediately after adding the line.
        [switch]$Reload
    )

    # 1. Ensure the profile directory exists
    $ProfileDir = Split-Path -Path $Path -Parent
    if (-not (Test-Path -Path $ProfileDir -ErrorAction SilentlyContinue)) {
        Write-Verbose "Creating profile directory: $ProfileDir"
        New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
    }

    # 2. Check if the profile file exists and create it if necessary
    if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
        Write-Verbose "Creating profile file: $Path"
        New-Item -Path $Path -ItemType File -Force | Out-Null
    }

    # 3. Check for duplicates before appending
    $Content = Get-Content -Path $Path -Raw
    if ($Content -notmatch [regex]::Escape($Line)) {
        Write-Host "✅ Appending line to profile: $($Path)" -ForegroundColor Green
        
        # Append the line, ensuring a blank line separates it from previous content
        Add-Content -Path $Path -Value "`n$Line"
        
        # 4. Reload the profile if the -Reload switch was used
        if ($Reload) {
            Write-Host "🔄 Reloading profile..." -ForegroundColor Cyan
            . $Path
        }
    } else {
        Write-Host "ℹ️ Line already exists in profile: $($Path). Skipping." -ForegroundColor Yellow
    }
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

    $activityId = 100 
    $tool = [ToolInstall]::new()
    $tool.Name = $Name

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

        Write-Host "-----[ 🚧 Installing $Name 🚧 ]-----"
        Invoke-Expression $Script

        Write-Progress -Activity "Tool: $Name" -Status "Verifying installation..." -PercentComplete 70 -Id $activityId

        # Necessary to let env variables be set.
        # refreshenv from choco, does not work
        # Only the $env:Path ... does not works
        # Only the combination of the two works 
        # (the other 
        Sleep -Seconds 2
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
        if (Test-CliToolAvailability -Command $Command) {
            Write-Progress -Activity "Tool: $Name" -Status "✅ Verification successful. " -PercentComplete 80 -Id $activityId -Completed
            $tool.Status = [ToolStatus]::Installed
            Write-Progress -Activity "Tool: $Name" -Status "$Name found. Retrieving version ..." -PercentComplete 90 -Id $activityId
            try {
                $tool.Version = & $Command --version 2>&1
                Write-Progress -Activity "Tool $Name" -Status "Version found: $($tool.Version)" -PercentComplete 100 -Id $activityId -Completed 
            }catch{
                $tool.Version = "Undefined"
                Write-Progress -Activity "Tool: $Name" -Status "Version not found" -PercentComplete 100 -Id $activityId -Completed 
            }
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
#   TOOLS
# ------------------------------------------------------------------------------
$tools = @()

$tools += @{ 
  Name = 'chocolatey'; 
  Command = 'choco'; 
  Script = @'
    # Set Execution Policy to Bypass for the current PowerShell process only.
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    
    # Ensure Tls1.2 (or higher) is available, which is required for secure download.
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; # Tls1.2
    
    # Download and execute the official Chocolatey install script.
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
'@}

$tools += @{ 
  Name = "Oh My Posh"; 
  Command = "oh-my-posh"; 
  Script = @'
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
'@}


# ------------------------------------------------------------------------------
#   MAIN EXECUTION
# ------------------------------------------------------------------------------
Write-Host "--------------------------------------------------------------------------------"
Write-Host " ⚒️ SETUP: Development Environment for Windows"
Write-Host "--------------------------------------------------------------------------------"

$currentToolIndex = 0
$progressId       = 1 # ID for the main progress bar
$statusLine       = ""

# Loop through all tools and install if missing
for ($i = 0; $i -lt $tools.Count; $i++) {

    $tool = $tools[$i]
    
    # Update the main progress bar before starting the tool
    Write-Progress -Activity "Installing tools" `
                   -Status "$($tool.Name) (Step $($i + 1) of $($tools.Count))" `
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
        ([ToolStatus]::Installed)      { "($($result.Version)) - Installed " }
        ([ToolStatus]::AlreadyPresent) { "($($result.Version)) - Already installed" }
        ([ToolStatus]::Failed)         { "- Installation failed. See errors above." }
        default                        { "" }
    }

    Write-Host "$prefix $($result.Name) $suffix"
}

Write-Progress -Activity "Installing Tools" -Status "All checks complete." -Completed -Id $progressId
Write-Host "" 
Write-Host "ℹ️ Restart terminal to load changes !"
