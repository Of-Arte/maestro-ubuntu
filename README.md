# Maestro Ubuntu Installer

A standalone Ubuntu 24.04 LTS-based development environment for Maestro AI Software Engineering students.

## Quickstart

```bash
git clone https://github.com/Of-Arte/maestro-ubuntu-installer.git
cd maestro-ubuntu-installer
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
