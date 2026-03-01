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

# Identity Setup (skip if headless)
setup_identity() {
    if [[ "${MAESTRO_HEADLESS:-0}" == "1" ]] || [[ "$*" == *"--headless"* ]]; then
        echo "Headless mode: Skipping desktop customizations."
        return 0
    fi

    echo "Setting up Maestro identity..."
    # Install fastfetch
    sudo apt-get install -y fastfetch

    # Set Wallpaper (GNOME)
    WALLPAPER_PATH="$REPO_ROOT/desktop/assets/maestro_wallpaper.png"
    if [[ -f "$WALLPAPER_PATH" ]]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
    fi

    # UI Preferences
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface clock-format '12h'

    # Refresh welcome script in home
    echo "Refreshing welcome script in $HOME/desktop/..."
    mkdir -p "$HOME/desktop"
    cp "$REPO_ROOT/desktop/maestro-welcome.sh" "$HOME/desktop/"
    cp "$REPO_ROOT/desktop/keybinds.md" "$HOME/desktop/"
    chmod +x "$HOME/desktop/maestro-welcome.sh"
}

# Pre-flight check for essentials
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    sudo apt-get update && sudo apt-get install -y curl
fi

if ! command -v git &> /dev/null; then
    echo "Installing git..."
    sudo apt-get install -y git
fi

# Handle --identity-only flag
if [[ "$*" == *"--identity-only"* ]]; then
    setup_identity "$@"
    echo "Identity setup complete!"
    exit 0
fi

setup_identity "$@"

# Call base tier
bash "$REPO_ROOT/tiers/base.sh"

echo "Creating /usr/local/bin/maestro CLI..."
cat << EOF | sudo tee /usr/local/bin/maestro > /dev/null
#!/bin/bash
set -euo pipefail

export REPO_ROOT="$REPO_ROOT"

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
    setup-identity)
        # We need to source or redefine the function here since it's in the installer
        # For simplicity, we'll just run the install script with a specific flag
        # or we can extract it. Let's just call install.sh with --identity-only
        bash "\$REPO_ROOT/install.sh" --identity-only
        ;;
    validate)
        bash "\$REPO_ROOT/validate.sh"
        ;;
    version)
        echo "Maestro Stack Installer v0.1"
        ;;
    *)
        echo "Usage: maestro {install [web|ai] | setup-identity | validate | version}"
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
