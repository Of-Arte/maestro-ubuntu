# Maestro Ubuntu Installer

A standalone Ubuntu 24.04 LTS-based development environment for Maestro AI Software Engineering students.

## Quickstart (One-Liner)

To install the Maestro Stack on a fresh Ubuntu 24.04 LTS system:

```bash
curl -sS https://raw.githubusercontent.com/Of-Arte/maestro-ubuntu/main/install.sh | bash
```

### CLI-Only / Headless Mode
If you are running on a server or don't want the custom wallpaper/GNOME branding:
```bash
curl -sS https://raw.githubusercontent.com/Of-Arte/maestro-ubuntu/main/install.sh | bash -s -- --headless
```

---

## Manual Install

```bash
# Bootstrap git (required for fresh installs if curl is not used)
sudo apt update && sudo apt install -y git

# Clone and install
git clone https://github.com/Of-Arte/maestro-ubuntu.git
cd maestro-ubuntu
chmod +x install.sh
./install.sh
```

## Structure

- `install.sh`: Entry point, idempotent, fully automated. Installs the base tier.
- `validate.sh`: Smoke tests to verify the installation.
- `tiers/`: Individual installer scripts for Base, Web, and AI tiers.
- `stack/`: Pinned runtime versions, apt packages, and more.
- `desktop/`: Custom scripts and configuration for the end-user desktop experience.
- `vm/`: Utilities to package the installation as an OVA for VirtualBox.

## Commands

Once installed, the `maestro` CLI is available globally:

- `maestro validate`: Validate current tier installation.
- `maestro install web`: Install Web (FE + BE) stack.
- `maestro install ai`: Install AI/ML stack.
- `maestro version`: View the CLI version.
