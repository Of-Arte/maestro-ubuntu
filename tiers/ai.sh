#!/bin/bash
set -euo pipefail

echo "===================================================="
echo " Maestro Stack Installer - AI Tier"
echo "===================================================="

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

source "$REPO_ROOT/stack/runtime.versions"
source "$REPO_ROOT/stack/utils.sh"

echo "Setting up Python virtual environment for AI Tier..."
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.maestro/venvs"
if [ ! -d "$HOME/.maestro/venvs/ai" ]; then
    with_retries uv venv "$HOME/.maestro/venvs/ai" --python "$PYTHON_VERSION"
fi

echo "Installing Python AI packages..."
with_retries uv pip install \
    numpy pandas scipy matplotlib seaborn \
    scikit-learn xgboost jupyterlab \
    torch torchvision \
    transformers huggingface-hub \
    openai anthropic \
    langchain langchain-community langgraph \
    chromadb websockets rich \
    pydantic python-dotenv \
    --python "$HOME/.maestro/venvs/ai"

echo "Installing Ollama pinned to $OLLAMA_VERSION..."
if [ "$OLLAMA_VERSION" = "latest" ]; then
    with_retries curl -fsSL https://ollama.com/install.sh | sh
else
    with_retries curl -fsSL https://ollama.com/install.sh | OLLAMA_VERSION="$OLLAMA_VERSION" sh
fi

echo "Enabling Ollama service..."
sudo systemctl enable --now ollama

echo "Pulling Docker images for AI stack..."
if ! docker info >/dev/null 2>&1; then
    echo "WARNING: Docker is not accessible without sudo. Using sudo for pulls."
    with_retries sudo docker pull rabbitmq:3-management
else
    with_retries docker pull rabbitmq:3-management
fi

echo "===================================================="
echo "AI tier installation complete!"
echo "NOTE: PyTorch is installed with default settings (likely CPU on VM)."
echo "===================================================="
