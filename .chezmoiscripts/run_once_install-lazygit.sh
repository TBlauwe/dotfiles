#!/bin/bash
if command -v lazygit >/dev/null 2>&1; then
    echo "Lazygit is already installed."
else
    echo "Installing Lazygit locally..."
    # Fetch latest version tag
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

    # Download tarball
    URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    curl -Lo lazygit.tar.gz "$URL"

    # Extract and install to local bin
    mkdir -p ~/.local/bin
    tar xf lazygit.tar.gz lazygit
    mv lazygit ~/.local/bin/
    rm lazygit.tar.gz
    echo "Lazygit installed to ~/.local/bin/lazygit"
fi
