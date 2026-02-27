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

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call base tier
bash "$REPO_ROOT/tiers/base.sh"

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
