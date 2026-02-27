```markdown
# Project Maestro Ubuntu — Context Brief

## What we are building
A standalone Ubuntu 24.04 LTS-based development environment for
Maestro AI Software Engineering students. This is a companion to the
Maestro Omarchy ISO, optimized specifically for VM-based usage on
mixed hardware (Windows, macOS, existing Linux). Students get a
VirtualBox-ready `.ova` appliance OR a bootable ISO, both provisioned
with the identical Maestro AI SWE stack via the same tiered installer.

## Why Ubuntu LTS alongside Omarchy
Omarchy (Arch + Hyprland) is the bare metal target for students with
dedicated machines. Ubuntu LTS is the VM and low-end device target:
- Rock-solid VirtualBox compatibility, no Wayland/GPU hacks required
- 5-year LTS support cycle, no rolling release breakage risk
- Larger support community, better documented error messages
- Identical stack underneath — same tools, same tiers, same curriculum

## Who it is for
- Students testing the environment before getting their primary machine
- Students on Windows or macOS who need a VM-based Linux environment
- Low-end device users who cannot run Hyprland comfortably
- Any student who needs a working environment in under 15 minutes

## Repo name
`maestro-ubuntu-installer`

## Repo structure to create
```
maestro-ubuntu-installer/
├── README.md
├── install.sh              # entry point, idempotent, fully automated
├── validate.sh             # smoke tests per tier
├── tiers/
│   ├── base.sh             # always installed (Term 1-3)
│   ├── web.sh              # FE + BE stack (Term 3-6)
│   └── ai.sh               # AI/ML stack (Term 7-9)
├── stack/
│   ├── apt.txt             # Ubuntu apt packages (base tier)
│   ├── runtime.versions    # pinned runtime versions
│   └── pip.txt             # Python packages installed via uv
├── vm/
│   ├── build-ova.sh        # builds VirtualBox .ova from running VM
│   └── Vagrantfile         # optional: Vagrant wrapper for automation
└── desktop/
    ├── keybinds.md         # student-facing keybind reference
    └── maestro-welcome.sh  # runs on first login, prints getting started
```

## Base OS
- **Ubuntu 24.04 LTS** (Noble Numbat)
- **Desktop environment:** GNOME (Ubuntu default, VirtualBox compatible)
- **Display server:** X11 (not Wayland) for maximum VM compatibility
- **Terminal:** GNOME Terminal (pre-installed, no GPU dependency)

## Design principles
- Idempotent: every script is safe to run twice without side effects
- Pinned: all runtime versions locked in `stack/runtime.versions`
- Tiered: install only what the current term requires
- Docker for services: Postgres, Redis, MongoDB, RabbitMQ run in containers
- Host for runtimes: Python, Node, Docker installed directly on host
- No credentials: zero private keys, tokens, or hardcoded usernames
- No interactive prompts: fully automated, unattended installs only
- Exit on error: `set -euo pipefail` in every script

## stack/runtime.versions content
```
PYTHON_VERSION=3.12.2
NODE_VERSION=20.12.2
PNPM_VERSION=9.1.4
UV_VERSION=0.4.18
OLLAMA_VERSION=latest
DOCKER_COMPOSE_VERSION=v2.27.0
```

## stack/apt.txt content (base tier)
```
git
gh
curl
wget
zip
unzip
build-essential
openssh-client
zsh
tmux
ripgrep
fzf
htop
btop
jq
make
shellcheck
docker.io
docker-compose-plugin
python3
python3-pip
python3-venv
nodejs
npm
openssl
xclip
ca-certificates
gnupg
```

## tiers/base.sh must
1. `set -euo pipefail`
2. Source `stack/runtime.versions`
3. Update apt: `apt-get update && apt-get upgrade -y`
4. Install all packages in `stack/apt.txt` via `apt-get install -y`
5. Install Node LTS via `nvm` pinned to `NODE_VERSION`
6. Install `uv` pinned to `UV_VERSION`
7. Install `pnpm` pinned to `PNPM_VERSION` via npm
8. Enable and start Docker: `systemctl enable --now docker`
9. Add `$USER` to docker group: `usermod -aG docker $USER`
10. Set zsh as default shell: `chsh -s $(which zsh) $USER`
11. Install oh-my-zsh (unattended)
12. Run `desktop/maestro-welcome.sh` setup
13. Print completion message with next steps

## tiers/web.sh must
1. `set -euo pipefail`
2. Source `stack/runtime.versions`
3. Install globally via pnpm:
   `typescript`, `vite`, `eslint`, `prettier`
4. Install Python web packages via uv into `~/.maestro/venvs/web`:
   `fastapi`, `uvicorn`, `httpx`, `python-dotenv`, `pydantic`,
   `pytest`, `pytest-cov`, `black`, `ruff`, `pre-commit`
5. Pull Docker images (do not start containers):
   `postgres:16`, `redis:7`, `mongo:7`
6. Install via apt: `httpie`, `pgcli`, `litecli`, `nginx`
7. Install `dbeaver-ce` via official `.deb` download (pin version)
8. Install `playwright` browsers: `pnpm exec playwright install`

## tiers/ai.sh must
1. `set -euo pipefail`
2. Source `stack/runtime.versions`
3. Install Python AI packages via uv into `~/.maestro/venvs/ai`:
   `numpy`, `pandas`, `scipy`, `matplotlib`, `seaborn`,
   `scikit-learn`, `xgboost`, `jupyterlab`,
   `torch`, `torchvision`,
   `transformers`, `huggingface-hub`,
   `openai`, `anthropic`,
   `langchain`, `langchain-community`, `langgraph`,
   `chromadb`, `websockets`, `rich`,
   `pydantic`, `python-dotenv`
4. Install Ollama via official script pinned to `OLLAMA_VERSION`
5. Enable Ollama as systemd service
6. Pull Docker images: `rabbitmq:3-management`
7. TODO: PyTorch CPU vs GPU variant — detect GPU at install time
   and pull appropriate wheel. Default to CPU for VM safety.

## install.sh must
1. `set -euo pipefail`
2. Check Ubuntu version — exit with clear error if not 24.04
3. Print "Maestro Stack Installer v0.1 — Base Tier" header
4. Call `tiers/base.sh`
5. Create `/usr/local/bin/maestro` CLI with subcommands:
   - `maestro install web`  → runs `tiers/web.sh`
   - `maestro install ai`   → runs `tiers/ai.sh`
   - `maestro validate`     → runs `validate.sh`
   - `maestro version`      → prints current stack version
6. Print post-install instructions:
   - Log out and back in (docker group + zsh take effect)
   - Run `maestro validate` to confirm base tier
   - Run `maestro install web` when starting Term 3

## validate.sh must check
- Ubuntu version is 24.04
- Python version matches `runtime.versions`
- Node version matches `runtime.versions`
- Docker daemon is running and `docker run hello-world` passes
- `git --version` exits 0
- `uv --version` exits 0
- `pnpm --version` exits 0
- `zsh --version` exits 0
- `maestro` CLI exists and responds to `maestro version`
- Print PASS/FAIL per check with clear labels
- Print summary: X passed, Y failed
- Exit 1 if any check fails

## vm/build-ova.sh must
1. Print instructions for taking a clean VirtualBox snapshot
2. Export the current VM as a `.ova` using VBoxManage:
   `VBoxManage export <vmname> --output maestro-ubuntu-v0.1.ova`
3. Print SHA256 checksum of the output file
4. Print distribution instructions

## desktop/maestro-welcome.sh must
- Print on first terminal open:
  - "Welcome to Maestro Ubuntu v0.1"
  - Current term and what tools are available
  - How to install the next tier (`maestro install web`)
  - How to validate (`maestro validate`)
  - Link to keybinds.md

## desktop/keybinds.md must include
GNOME + Ubuntu keyboard shortcuts relevant to developers:
- Terminal, browser, file manager
- Workspace switching
- Window snapping
- Screenshot
- Any Maestro-specific shortcuts added via GNOME settings

## Curriculum coverage (same as Omarchy ISO)
| Course | Tier | Key tools |
|--------|------|-----------|
| PY101 Python | Base | Python 3.12, uv, pytest, ruff |
| CS101 SWE Principles | Base | git, gh, make, shellcheck |
| CS102 Data Structures | Base | Python, matplotlib, jupyter |
| CS103 OOP | Base | Python |
| FE101 Web Dev | Web | Node 20, pnpm, Vite, Chromium |
| FE102 Interactive UIs | Web | TypeScript, React, Tailwind, ESLint |
| FE103 Frontend Project | Web | Playwright |
| BE101 Backend Dev | Web | FastAPI, uvicorn, Docker |
| BE102 RESTful APIs | Web | httpie, httpx, jq |
| BE103 Databases | Web | Postgres, SQLite, MongoDB, Redis |
| BE104 Auth Middleware | Web | python-jose, passlib, nginx |
| BE105 Microservices | Web | RabbitMQ, Caddy, grpcurl |
| BE106 Backend Project | Web | Full web tier |
| AI101 AI Math | AI | numpy, pandas, scipy, jupyter |
| AI102 ML | AI | scikit-learn, PyTorch, xgboost |
| AI103 Prompt LLMs | AI | openai, anthropic, langchain, ollama |
| AI104 Capstone | AI | langgraph, chromadb, fastapi, rich |

## Relationship to Omarchy ISO
Both repos share:
- Identical `stack/runtime.versions` (single source of truth for versions)
- Identical tier structure (base, web, ai)
- Identical `maestro` CLI interface
- Identical `validate.sh` logic

They differ only in:
- Package manager (`apt` vs `pacman`)
- Desktop environment (GNOME/X11 vs Hyprland/Wayland)
- ISO build pipeline (Ubuntu ISO vs Omarchy ISO builder)

A student moving from Ubuntu VM to Omarchy bare metal gets the
exact same tools, same commands, same workflow. Zero relearning.

## Update policy
1. Bump versions in `stack/runtime.versions`
2. Tag installer repo release (`v0.2`)
3. Rebuild `.ova` using `vm/build-ova.sh`
4. Run `maestro validate` inside fresh VM to confirm
5. Publish `.ova` download link + SHA256 checksum

## Current status
- [ ] Repo scaffolded
- [ ] Base tier tested in VirtualBox
- [ ] Web tier tested in VirtualBox
- [ ] AI tier tested in VirtualBox
- [ ] `.ova` exported and validated
- [ ] SHA256 checksum published

## Do not include
- Any private keys, tokens, or API credentials
- Hardcoded usernames (use `$USER` and `$HOME`)
- Interactive prompts of any kind
- VS Code or proprietary editors
- Anything that requires a GUI to install
```