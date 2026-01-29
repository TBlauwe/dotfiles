if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Write-Host "Lazygit is already installed."
} else {
    Write-Host "Installing Lazygit via Winget..."
    winget install jesseduffield.lazygit
}

