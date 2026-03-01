#!/bin/bash
set -euo pipefail

echo "=========================================================="
echo "      Maestro Stack Installer v0.1 — Base Tier"
echo "=========================================================="

# Check Ubuntu version
UBUNTU_VERSION=$(grep -Po '(?<=^VERSION_ID=")[^"]*' /etc/os-release || echo "unknown")
if [[ "$UBUNTU_VERSION" != "24.04" ]]; then
    echo "ERROR: Maestro Ubuntu requires Ubuntu 24.04 LTS."
    echo "Current version detected: $UBUNTU_VERSION"
    exit 1
fi

# Check if running as a one-liner (bootstrap needed)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -d "$REPO_ROOT/tiers" ]]; then
    echo "Bootstrap: Downloading Maestro Ubuntu stack..."
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/Of-Arte/maestro-ubuntu.git "$TEMP_DIR"
    cd "$TEMP_DIR"
    exec bash install.sh "$@"
fi


# Hardening: Network Retry Wrapper
with_retries() {
    local n=1
    local max=3
    local delay=5
    while true; do
        "$@" && break || {
            if [[ $n -lt $max ]]; then
                ((n++))
                echo "Command failed. Attempt $n/$max in ${delay}s..."
                sleep $delay
            else
                echo "The command has failed after $max attempts."
                return 1
            fi
        }
    done
}

# Pre-flight check for essentials (Hardened)
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    with_retries sudo apt-get update
    with_retries sudo apt-get install -y curl
fi

if ! command -v git &> /dev/null; then
    echo "Installing git..."
    with_retries sudo apt-get install -y git
fi


# Call base tier
if [[ -f "$REPO_ROOT/tiers/base.sh" ]]; then
    bash "$REPO_ROOT/tiers/base.sh"
else
    echo "ERROR: Base tier script not found at $REPO_ROOT/tiers/base.sh"
    exit 1
fi

echo "Creating /usr/local/bin/maestro CLI..."
cat << EOF | sudo tee /usr/local/bin/maestro > /dev/null
#!/bin/bash
set -euo pipefail

export REPO_ROOT="$REPO_ROOT"

case "\$1" in
    install)
        if [ "\$2" == "web" ]; then
            bash "\$REPO_ROOT/tiers/web.sh"
        elif [ "\$2" == "ai" ]; then
            bash "\$REPO_ROOT/tiers/ai.sh"
        else
            echo "Usage: maestro install [web|ai]"
            exit 1
        fi
        ;;
    uninstall)
        bash "\$REPO_ROOT/uninstall.sh"
        ;;
    validate)
        bash "\$REPO_ROOT/validate.sh"
        ;;
    version)
        echo "Maestro Stack Installer v0.1"
        ;;
    *)
        echo "Usage: maestro {install [web|ai] | validate | version}"
        exit 1
        ;;
esac
EOF

sudo chmod +x /usr/local/bin/maestro

echo "=========================================================="
echo "Installation complete!"
echo "Post-install instructions:"
echo "- Log out and back in (docker group + zsh take effect)"
echo "- Run 'maestro validate' to confirm base tier"
echo "- Run 'maestro install web' when starting Term 3"
echo "=========================================================="
