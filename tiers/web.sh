#!/bin/bash
set -euo pipefail

echo "===================================================="
echo " Maestro Stack Installer - Web Tier"
echo "===================================================="

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

source "$REPO_ROOT/stack/runtime.versions"
source "$REPO_ROOT/stack/utils.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Setting up pnpm environment..."
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

echo "Installing global npm packages via pnpm..."
with_retries pnpm install -g typescript vite eslint prettier

echo "Setting up Python virtual environment for Web Tier..."
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.maestro/venvs"
if [ ! -d "$HOME/.maestro/venvs/web" ]; then
    with_retries uv venv "$HOME/.maestro/venvs/web" --python "$PYTHON_VERSION"
fi

echo "Installing Python web packages..."
with_retries uv pip install \
    fastapi uvicorn httpx python-dotenv pydantic \
    pytest pytest-cov black ruff pre-commit \
    --python "$HOME/.maestro/venvs/web"

echo "Pulling Docker images for web stack..."
if ! docker info >/dev/null 2>&1; then
    echo "WARNING: Docker is not accessible without sudo. Using sudo for pulls."
    with_retries sudo docker pull postgres:16
    with_retries sudo docker pull redis:7
    with_retries sudo docker pull mongo:7
else
    with_retries docker pull postgres:16
    with_retries docker pull redis:7
    with_retries docker pull mongo:7
fi

echo "Installing Web tier apt packages..."
with_retries sudo DEBIAN_FRONTEND=noninteractive apt-get install -y httpie pgcli litecli nginx

echo "Installing dbeaver-ce..."
with_retries wget -qO /tmp/dbeaver-ce.deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
sudo dpkg -i /tmp/dbeaver-ce.deb || sudo apt-get install -f -y
rm /tmp/dbeaver-ce.deb

echo "Installing Playwright browsers..."
with_retries pnpm dlx playwright install

echo "===================================================="
echo "Web tier installation complete!"
echo "===================================================="
