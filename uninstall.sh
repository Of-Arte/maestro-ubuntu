#!/bin/bash
set -euo pipefail

echo "=========================================================="
echo "          Maestro Stack Uninstaller"
echo "=========================================================="

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Identify installed components
echo "Uninstalling Maestro CLI..."
sudo rm -f /usr/local/bin/maestro

echo "Removing Maestro directories..."
rm -rf "$HOME/.maestro"
rm -f "$HOME/desktop/maestro-welcome.sh"
rm -f "$HOME/desktop/keybinds.md"

echo "Cleaning up shell configurations..."
# Remove maestro-welcome.sh from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/maestro-welcome.sh/d' "$HOME/.zshrc"
    sed -i '/PNPM_HOME/d' "$HOME/.zshrc"
fi

# Remove from .bashrc
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/PNPM_HOME/d' "$HOME/.bashrc"
fi

echo "Removing core packages (optional, keeping Docker for safety)..."
# We could uninstall everything in apt.txt, but that might break other things
# Let's just remove the identity-specific ones we added
sudo apt-get remove -y fastfetch || true

echo "Resetting GNOME settings..."
gsettings reset org.gnome.desktop.background picture-uri
gsettings reset org.gnome.desktop.background picture-uri-dark
gsettings reset org.gnome.desktop.interface color-scheme
gsettings reset org.gnome.desktop.interface clock-format

echo "=========================================================="
echo "Uninstallation complete!"
echo "Note: Base packages, Docker, and NVM were kept to avoid"
echo "unintended side effects. You can remove them manually if"
echo "needed."
echo "=========================================================="
