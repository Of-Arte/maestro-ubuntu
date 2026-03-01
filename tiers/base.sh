#!/bin/bash
set -euo pipefail

echo "===================================================="
echo " Maestro Stack Installer - Base Tier"
echo "===================================================="

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

source "$REPO_ROOT/stack/runtime.versions"
source "$REPO_ROOT/stack/utils.sh"

echo "Updating apt..."
with_retries sudo apt-get update
with_retries sudo apt-get upgrade -y

echo "Setting up official Docker repository..."
sudo install -m 0755 -d /etc/apt/keyrings
with_retries sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
with_retries sudo apt-get update

echo "Installing apt packages..."
with_retries sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $(cat "$REPO_ROOT/stack/apt.txt")

echo "Installing Node LTS via nvm pinned to $NODE_VERSION..."
with_retries curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
with_retries nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use default

echo "Installing uv pinned to $UV_VERSION..."
with_retries curl -LsSf https://astral.sh/uv/install.sh | env UV_VERSION="$UV_VERSION" sh

echo "Installing pnpm pinned to $PNPM_VERSION via npm..."
with_retries npm install -g pnpm@"$PNPM_VERSION"

echo "Configuring pnpm..."
export PNPM_HOME="$HOME/.local/share/pnpm"
mkdir -p "$PNPM_HOME"
export PATH="$PNPM_HOME:$PATH"
pnpm config set global-bin-dir "$PNPM_HOME"

# Add PNPM_HOME to shell configs if not present
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q "PNPM_HOME" "$rc"; then
        echo "export PNPM_HOME=\"\$HOME/.local/share/pnpm\"" >> "$rc"
        echo "export PATH=\"\$PNPM_HOME:\$PATH\"" >> "$rc"
    fi
done

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
