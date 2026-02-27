#!/bin/bash
set -euo pipefail

echo "===================================================="
echo " Maestro Stack Installer - Base Tier"
echo "===================================================="

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

source "$REPO_ROOT/stack/runtime.versions"

echo "Updating apt..."
sudo apt-get update
sudo apt-get upgrade -y

echo "Installing apt packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $(cat "$REPO_ROOT/stack/apt.txt")

echo "Installing Node LTS via nvm pinned to $NODE_VERSION..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use default

echo "Installing uv pinned to $UV_VERSION..."
curl -LsSf https://astral.sh/uv/install.sh | env UV_VERSION="$UV_VERSION" sh

echo "Installing pnpm pinned to $PNPM_VERSION via npm..."
npm install -g pnpm@"$PNPM_VERSION"

echo "Configuring Docker..."
sudo systemctl enable --now docker
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"

echo "Configuring Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" "$USER"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh (unattended)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "Setting up welcome script..."
mkdir -p "$HOME/desktop"
cp "$REPO_ROOT/desktop/maestro-welcome.sh" "$HOME/desktop/"
cp "$REPO_ROOT/desktop/keybinds.md" "$HOME/desktop/"
chmod +x "$HOME/desktop/maestro-welcome.sh"

if ! grep -q "maestro-welcome.sh" "$HOME/.zshrc" 2>/dev/null; then
    echo "~/desktop/maestro-welcome.sh" >> "$HOME/.zshrc"
fi

echo "===================================================="
echo "Base tier installation complete!"
echo "Next steps:"
echo "- Log out and back in (or restart VM) for docker group and zsh to take effect"
echo "- Run 'maestro validate' to confirm base tier"
echo "- Run 'maestro install web' when starting Term 3"
echo "===================================================="
