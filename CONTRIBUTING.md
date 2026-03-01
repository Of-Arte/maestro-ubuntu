# Contributing to Maestro Ubuntu

Thanks for helping improve this project.

## How it works

The installer is a set of Bash scripts. Each tier (`base`, `web`, `ai`) is independently runnable. All scripts must be idempotent — safe to run twice without side effects.

## Prerequisites

- Ubuntu 24.04 LTS (required for testing)
- VirtualBox (recommended for a clean environment)
- `shellcheck` for linting

## Running locally

```bash
git clone https://github.com/Of-Arte/maestro-ubuntu.git
cd maestro-ubuntu
chmod +x install.sh
./install.sh
```

After install:

```bash
maestro validate       # confirm base tier
maestro install web    # install web tier
maestro install ai     # install AI tier
```

## Coding conventions

- Every script starts with `set -euo pipefail`
- Use `with_retries` for any network operations
- No hardcoded usernames — use `$USER` and `$HOME`
- No interactive prompts of any kind
- Run `shellcheck` before opening a PR:
  ```bash
  shellcheck install.sh validate.sh uninstall.sh tiers/*.sh
  ```

## Submitting a PR

1. Fork the repo and create a branch from `main`
2. Make your changes, test on a clean Ubuntu 24.04 VM
3. Make sure CI passes
4. Open a pull request with a clear description of what changed and why

## Pinned versions

Runtime versions live in `stack/runtime.versions`. Bump versions there first, then test the full install before proposing a version upgrade.

## Reporting bugs

Open a GitHub Issue with:
- Ubuntu version (`lsb_release -a`)
- The exact command you ran
- Full output, including any error messages

## Scope

This repo installs the Maestro AI Software Engineering stack on Ubuntu 24.04 LTS. Changes outside that scope (different distros, different desktop environments, cloud provisioning) are out of scope for this repo.
