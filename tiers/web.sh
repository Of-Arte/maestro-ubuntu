#!/bin/bash
set -euo pipefail

echo "===================================================="
echo " Maestro Stack Installer - Web Tier"
echo "===================================================="

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

source "$REPO_ROOT/stack/runtime.versions"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Setting up pnpm environment..."
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

echo "Installing global npm packages via pnpm..."
pnpm install -g typescript vite eslint prettier

echo "Setting up Python virtual environment for Web Tier..."
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.maestro/venvs"
if [ ! -d "$HOME/.maestro/venvs/web" ]; then
    uv venv "$HOME/.maestro/venvs/web" --python "$PYTHON_VERSION"
fi

echo "Installing Python web packages..."
uv pip install \
    fastapi uvicorn httpx python-dotenv pydantic \
    pytest pytest-cov black ruff pre-commit \
    --python "$HOME/.maestro/venvs/web"

echo "Pulling Docker images for web stack..."
if ! docker info >/dev/null 2>&1; then
    echo "WARNING: Docker is not accessible without sudo. Using sudo for pulls."
    sudo docker pull postgres:16
    sudo docker pull redis:7
    sudo docker pull mongo:7
else
    docker pull postgres:16
    docker pull redis:7
    docker pull mongo:7
fi

echo "Installing Web tier apt packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y httpie pgcli litecli nginx

echo "Installing dbeaver-ce..."
wget -qO /tmp/dbeaver-ce.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
sudo dpkg -i /tmp/dbeaver-ce.deb || sudo apt-get install -f -y
rm /tmp/dbeaver-ce.deb

echo "Installing Playwright browsers..."
pnpm exec playwright install

echo "===================================================="
echo "Web tier installation complete!"
echo "===================================================="
