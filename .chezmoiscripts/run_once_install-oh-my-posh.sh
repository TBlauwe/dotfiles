#!/bin/bash
if command -v oh-my-posh >/dev/null 2>&1; then
    echo "Oh My Posh is already installed."
else
    echo "Installing Oh My Posh locally..."
    # Official install script, directed to ~/.local/bin
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi

