# Dotfiles Bootstrap

This repository is a **public bootstrapper** for my personal dotfiles, which are managed with
[chezmoi](https://www.chezmoi.io/) and live in a **separate, private repository**.

Its only job is to give me (and future-me) a safe, one‑liner to bring a new machine or environment
up to speed without leaking secrets.

---

## What this repo is (and is not)

**This repo is:**

- Public
- Minimal
- Safe to `curl | bash`
- Focused on installing `chezmoi` and nothing else

**This repo is not:**

- My actual dotfiles
- A place where secrets live
- A general-purpose setup script

All real configuration, secrets, and templates live in my private dotfiles repo.

---

## Quick start (one‑liners)

### Default (SSH, preferred on personal machines)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkhnsn/dotfiles-bootstrap/main/install.sh)"
```

This assumes:

- You have SSH access to GitHub (for example via the 1Password SSH agent)
- You want the full dotfiles applied

---

### HTTPS fallback (no SSH keys yet)

```bash
DOTFILES_USE_HTTPS=1 \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkhnsn/dotfiles-bootstrap/main/install.sh)"
```

Useful on:

- Fresh machines
- Temporary servers
- Locked‑down environments

---

### Pin to a branch or tag

```bash
DOTFILES_REF=main \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkhnsn/dotfiles-bootstrap/main/install.sh)"
```

---

## How it works

1. Detects the OS (macOS or Linux)
2. Installs `chezmoi` if it isn’t already present
3. Runs:
   ```bash
   chezmoi init --apply <private-dotfiles-repo>
   ```
4. Hands control over to `chezmoi` for everything else

That’s it. No side effects beyond what my dotfiles explicitly configure.

---

## GitHub Codespaces

For Codespaces, this repository is **not used directly**.

Instead:

- GitHub’s **Dotfiles** feature is pointed at the private dotfiles repo
- GitHub automatically runs the appropriate setup scripts (`install.sh`, `bootstrap`, etc.)
- This keeps Codespaces behavior aligned with GitHub’s official documentation

---

## Security notes

- This repo contains **no secrets**
- OAuth tokens, SSH keys, and API credentials are stored in **1Password**
- Secrets are accessed at apply‑time using `chezmoi`’s 1Password integration
- Nothing sensitive is written to disk in this repo

If you’re auditing this repository before running it: good instinct 👍

---

## License

MIT. Do whatever you want with it — just don’t expect it to set up _your_ dotfiles 😉
