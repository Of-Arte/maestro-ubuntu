#!/bin/bash
set -euo pipefail

echo "===================================================="
echo " Maestro Stack Validation"
echo "===================================================="

cd "$(dirname "$0")"
REPO_ROOT="$(pwd)"
source "$REPO_ROOT/stack/runtime.versions"

PASSED=0
FAILED=0

check() {
    local name="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "[PASS] $name"
        : $((PASSED++))
    else
        echo "[FAIL] $name"
        : $((FAILED++))
    fi
}

# Relaxed version strings (Major.Minor)
PYTHON_MM="${PYTHON_VERSION%.*}"
NODE_MM="${NODE_VERSION%.*}"

check "Ubuntu 24.04 LTS" "grep -q 'VERSION_ID=\"24.04\"' /etc/os-release"
check "Python $PYTHON_MM" "python3 --version | grep -q '$PYTHON_MM'"
check "Node $NODE_MM" "source \$HOME/.nvm/nvm.sh && node --version | grep -q 'v$NODE_MM'"
check "Docker daemon running" "docker info"
check "Docker hello-world" "docker run --rm hello-world"
check "git" "git --version"
check "uv" "uv --version"
check "pnpm" "pnpm --version"
check "zsh" "zsh --version"
check "maestro CLI" "command -v maestro"
check "maestro CLI version" "maestro version"

# Web Tier Validation (if installed)
if [[ -d "$HOME/.maestro/venvs/web" ]]; then
    echo "--- Web Tier Detection ---"
    check "Web venv" "test -d $HOME/.maestro/venvs/web"
    check "FastAPI" "$HOME/.maestro/venvs/web/bin/pip list | grep -q fastapi"
    check "Postgres CLI" "command -v pgcli"
    check "Nginx" "command -v nginx"
fi

# AI Tier Validation (if installed)
if [[ -d "$HOME/.maestro/venvs/ai" ]]; then
    echo "--- AI Tier Detection ---"
    check "AI venv" "test -d $HOME/.maestro/venvs/ai"
    check "PyTorch" "$HOME/.maestro/venvs/ai/bin/pip list | grep -q torch"
    check "Ollama service" "systemctl is-active --quiet ollama"
    check "Ollama CLI" "command -v ollama"
fi

echo "===================================================="
echo "Summary: $PASSED passed, $FAILED failed"
echo "===================================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi
