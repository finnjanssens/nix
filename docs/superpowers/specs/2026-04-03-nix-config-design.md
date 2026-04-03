# Nix Config Design

**Date:** 2026-04-03
**Scope:** macOS-only nix configuration — zsh (oh-my-zsh), git. Structured to match `brancobruyneel/nixos-config`.

---

## Architecture

Flake-based nix-darwin + home-manager setup for a single macOS host.

- **Nixpkgs channel:** `nixpkgs-unstable`
- **Flake inputs:** `nixpkgs`, `nix-darwin`, `home-manager`
- **Host:** `Finns-MacBook-Pro-8` (`aarch64-darwin`, Apple Silicon M2)
- **User:** `finnjanssens`
- **Home-manager mode:** embedded as a nix-darwin module (not standalone)

### Wiring

`flake.nix` calls `lib/system/mk-darwin.nix` which constructs the full system by combining:
1. nix-darwin system config from `systems/aarch64-darwin/Finns-MacBook-Pro-8/default.nix`
2. home-manager user config from `homes/aarch64-darwin/finnjanssens@Finns-MacBook-Pro-8/default.nix`

---

## File Structure

```
nix/
├── flake.nix
├── flake.lock
├── lib/
│   └── system/
│       └── mk-darwin.nix
├── homes/
│   └── aarch64-darwin/
│       └── finnjanssens@Finns-MacBook-Pro-8/
│           └── default.nix
├── modules/
│   └── home/
│       └── development/
│           ├── default.nix
│           ├── zsh.nix
│           └── git.nix
└── systems/
    └── aarch64-darwin/
        └── Finns-MacBook-Pro-8/
            └── default.nix
```

---

## Zsh Module (`modules/home/development/zsh.nix`)

Configured via `programs.zsh` in home-manager.

- **dotDir:** `$XDG_CONFIG_HOME/zsh`
- **oh-my-zsh:** enabled
  - Theme: `robbyrussell`
  - Plugins: `aws`, `git`, `colorize`, `npm`, `yarn`, `history`, `httpie`, `ls`
- **External plugins** (via `programs.zsh.plugins` using nixpkgs sources):
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
- **History:**
  - Timestamps: `%d/%m/%y %T`
  - Dedup enabled
- **Session variables:**
  - `COMPLETION_WAITING_DOTS=true`
- **Aliases:**
  - `drb = "darwin-rebuild switch --flake ~/.config/nix"`

---

## Git Module (`modules/home/development/git.nix`)

Configured via `programs.git` in home-manager.

### Identity
- Name: `Finn Janssens`
- Email: `finn.janssens@inthepocket.com`

### Config
| Key | Value |
|-----|-------|
| `pull.rebase` | `true` |
| `rebase.autosquash` | `true` |
| `rebase.autoStash` | `true` |
| `push.autoSetupRemote` | `true` |
| `fetch.prune` | `true` |
| `core.autocrlf` | `input` |

### Colors
- `color.ui = auto`
- Branch: current=yellow bold, local=green bold, remote=cyan bold
- Diff: meta=yellow bold, frag=magenta bold, old=red bold, new=green bold, whitespace=red reverse
- Status: added=green bold, changed=yellow bold, untracked=red bold

### Aliases
| Alias | Command |
|-------|---------|
| `a` | `add` |
| `aa` | `add --all` |
| `c` | `commit -m` |
| `p` | `push` |
| `br` | `branch` |
| `cp` | `cherry-pick` |
| `nbr` | `!f() { git checkout -b $1 && git push --set-upstream origin $1; }; f` |
| `st` | `status` |
| `co` | `checkout` |
| `pu` | `pull` |
| `f` | `fetch` |
| `psuo` | `push --set-upstream origin` |

### Global gitignore
- `.DS_Store`
- `.direnv`
- `.envrc`
