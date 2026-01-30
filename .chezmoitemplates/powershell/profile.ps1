# ------------------------------------------------------------------------------
# 	COMMON
# ------------------------------------------------------------------------------
Set-PSReadlineOption -BellStyle None # Disable beep sound


# ----[ profile ]----------------------------------------------------------------
# Edit Powershell profile file
function profile {
	if (-not (Test-Path $PROFILE)) {
   		New-Item -Path $PROFILE -ItemType File -Force
	}
	vi $PROFILE
}


# ------------------------------------------------------------------------------
# 	CHEZMOI
# ------------------------------------------------------------------------------
$CHEZMOI = "~/.local/share/chezmoi/"


# ------------------------------------------------------------------------------
# 	VIM
# ------------------------------------------------------------------------------
Set-Alias -Name vim nvim
Set-Alias -Name vi nvim
Set-Alias -Name lg -Value lazygit

$VIM   = "$env:LOCALAPPDATA/nvim"
$SHADA = "$env:LOCALAPPDATA/nvim-data/shada/main.shada.tmp.X"

# Enable vim on the command line
Set-PSReadLineOption -EditMode Vi

# Bind 'j' and 'k' for history search in Command mode
Set-PSReadLineKeyHandler -Chord 'k' -ViMode Command -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord 'j' -ViMode Command -Function HistorySearchForward

# Ensure Ctrl+l clears the screen in Insert mode
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ViMode Insert -Function ClearScreen


# ------------------------------------------------------------------------------
#   DEV
# ------------------------------------------------------------------------------

# ----[ vs ]--------------------------------------------------------------------
# Setup Visual Studio Environment
function vs {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("amd64", "x86", "arm", "arm64")]
        [string]$Architecture = "amd64" # Default value is set here
    )

    # Use the environment variable for Program Files (x86)
    $VsDevCmdPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1"

    # --- Pre-Execution Checks ---
    if (-not (Test-Path -Path $VsDevCmdPath)) {
        Write-Error "Launch-VsDevShell.ps1 not found at '$VsDevCmdPath'. Please verify your Visual Studio 2022 Community installation path."
        Write-Error "The script is looking for VS 2022 Community. If you have a different version/edition, you must update the path in this script."
        return
    }

    # --- Construct and Execute Command ---
    Write-Host "Attempting to initialize Visual Studio Developer Environment for architecture: $Architecture" -ForegroundColor Cyan
    Write-Host "Source path: $VsDevCmdPath"

    # Save current location as the vs script change our current directory
    Push-Location

    # Use the call operator (&) to execute the batch file
    # This will execute the batch file and apply changes within the current scope.
    & $VsDevCmdPath -Arch $Architecture 

    # Get back to our saved location
    Pop-Location

    # Check if installation is correct
    if (Get-Command "cmake" -ErrorAction SilentlyContinue) {
        Write-Host "Visual Studio environment successfully configured for $Architecture build tools." -ForegroundColor Green
    } else {
        Write-Host "Error: cmake not found. Check architecture or script path." -ForegroundColor Red
    }
}


# ------------------------------------------------------------------------------
#   CEA	
# ------------------------------------------------------------------------------
$AIDGE                    = "$HOME/dev/aidge"
$AIDGE_CORE               = "$HOME/dev/aidge/aidge/aidge_core"
$AIDGE_BACKEND_CPU        = "$HOME/dev/aidge/aidge/aidge_backend_cpu"
$AIDGE_BACKEND_CUDA       = "$HOME/dev/aidge/aidge/aidge_backend_cuda"
$AIDGE_BACKEND_OPENCV     = "$HOME/dev/aidge/aidge/aidge_backend_opencv"
$AIDGE_CORE               = "$HOME/dev/aidge/aidge/aidge_core"
$AIDGE_EXPORT_ARM_CORTEXM = "$HOME/dev/aidge/aidge/aidge_export_arm_cortexm"
$AIDGE_EXPORT_CPP         = "$HOME/dev/aidge/aidge/aidge_export_cpp"
$AIDGE_EXPORT_TENSORRT    = "$HOME/dev/aidge/aidge/aidge_export_tensorrt"
$AIDGE_INTEROP_TORCH      = "$HOME/dev/aidge/aidge/aidge_interop_torch"
$AIDGE_LEARNING           = "$HOME/dev/aidge/aidge/aidge_learning"
$AIDGE_MODEL_EXPLORER     = "$HOME/dev/aidge/aidge/aidge_model_explorer"
$AIDGE_ONNX               = "$HOME/dev/aidge/aidge/aidge_onnx"
$AIDGE_QUANTIZATION       = "$HOME/dev/aidge/aidge/aidge_quantization"
$ACK                      = "$AIDGE/aidge-cmake-kit"


# ----[ aidge-venv ]------------------------------------------------------------
# Activate Aidge virtual environement
Set-Alias -Name aidge_venv $HOME/dev/aidge/.venv/Scripts/Activate.ps1

# ----[ SSH To CEA IS server ]------------------------------------------------------------
function Invoke-SshIS {
    & ssh td284617@is156025
}
Set-Alias -Name ssh-is Invoke-SshIS

function Invoke-SshUnixCI {
    & ssh admin-local@is248302
}
Set-Alias -Name ssh-unix-ci Invoke-SshUnixCI

function Invoke-Regen-Ack {
  Push-Location $ACK
  cmake -S . -B build/
  Pop-Location
}
Set-Alias -Name regen-ack Invoke-Regen-Ack


# ------------------------------------------------------------------------------
# 	Oh My Posh
# ------------------------------------------------------------------------------
$OH_MY_POSH = "$HOME/.tblauwe-theme.omp.json"

# Must be last !
oh-my-posh init pwsh --config $OH_MY_POSH | Invoke-Expression
