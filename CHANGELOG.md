# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.0](https://github.com/Of-Arte/maestro-ubuntu/compare/maestro-ubuntu-v0.1.0...maestro-ubuntu-v0.2.0) (2026-03-06)


### Features

* add future roadmap details and wallpaper visuals to documentation ([310a007](https://github.com/Of-Arte/maestro-ubuntu/commit/310a007dfb412938ce760b6b481cbf4a88039b92))
* Add web development tier setup script, fastfetch configuration, and desktop assets for Maestro Ubuntu. ([f742fe1](https://github.com/Of-Arte/maestro-ubuntu/commit/f742fe11a1448e9840153dc7e787e03538de19b1))


### Bug Fixes

* setup bootstrap, docker repository, and repo name consistency ([7db884d](https://github.com/Of-Arte/maestro-ubuntu/commit/7db884d0e0e62594893cea5073b76dd7867f6f15))

## [v0.1.0] — 2026-03-01

### Added

**Base Tier (`install.sh` + `tiers/base.sh`)**
- One-liner curl installer via `install.sh`
- Bootstrap mode: auto-clones repo if run piped from curl
- Network retry wrapper for resilience against transient failures
- Installs all packages in `stack/apt.txt` via official Docker apt repo + Ubuntu apt
- Node.js via nvm, pinned to version in `stack/runtime.versions`
- `uv` package manager, pinned version
- `pnpm`, pinned version
- Docker CE with daemon enabled and current user added to `docker` group
- Zsh + oh-my-zsh (unattended)
- `maestro` CLI at `/usr/local/bin/maestro`
- Welcome script copied to `~/desktop/maestro-welcome.sh`

**Web Tier (`tiers/web.sh`)**
- TypeScript, Vite, ESLint, Prettier via pnpm global
- Python web stack via uv in `~/.maestro/venvs/web`
- Docker images pulled: `postgres:16`, `redis:7`, `mongo:7`
- httpie, pgcli, litecli, nginx via apt
- DBeaver CE via official `.deb`
- Playwright browsers

**AI Tier (`tiers/ai.sh`)**
- Full AI/ML Python stack via uv in `~/.maestro/venvs/ai`
- Ollama installed and enabled as systemd service
- RabbitMQ management image pulled

**Validation (`validate.sh`)**
- PASS/FAIL checks for all base tier components
- Summary count with non-zero exit on any failure

**Uninstaller (`uninstall.sh`)**
- Removes `maestro` CLI, `~/.maestro`, welcome script
- Cleans shell rc files

**CI (`.github/workflows/ci.yml`)**
- Runs on push and pull request to `main`
- Installs base tier, validates, then tests uninstall

**Desktop**
- `desktop/keybinds.md`: GNOME keyboard reference for students
- `desktop/maestro-welcome.sh`: First-login greeting with next steps

**VM**
- `vm/build-ova.sh`: VirtualBox OVA export script with SHA256 output
- `vm/Vagrantfile`: Vagrant wrapper for automated VM provisioning
