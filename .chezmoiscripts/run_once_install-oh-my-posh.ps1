if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Host "Oh My Posh is already installed."
} else {
    Write-Host "Installing Oh My Posh via Winget..."
    winget install JanDeDobbeleer.OhMyPosh -s winget
}
