# Finn's Nix Config

Declarative macOS setup using [nix-darwin](https://github.com/LnL7/nix-darwin) and [Home Manager](https://github.com/nix-community/home-manager).

## What's managed

| Component | Type | Description |
| --- | --- | --- |
| acli | brew | Atlassian CLI for Jira/Confluence |
| arc | cask | Arc browser |
| aws-vault-binary | cask | Securely store and access AWS credentials |
| awscli2 | package | AWS command line interface |
| bat | module | Syntax-highlighted cat replacement |
| bruno | cask | Open source API client |
| claude-code | module | Anthropic's CLI for Claude with permission profiles, plugins, and agents |
| colima | package | Container runtime for macOS (Docker compatible) |
| delta | package | Syntax-highlighted git diffs |
| direnv | module | Per-project environment variables and dev shells |
| docker | package | Docker CLI client |
| eza | module | Modern ls replacement with git integration |
| fzf | module | Fuzzy finder for files, history, and tab completion |
| ghostty | cask | GPU-accelerated terminal emulator |
| git | module | Version control with delta, aliases, and global ignores |
| glab | package | GitLab CLI |
| go | package | Go programming language |
| lazydocker | package | Terminal UI for Docker container management |
| neovim | module | Text editor with LSP, Treesitter, and telescope |
| nerd-fonts-jetbrains-mono | package | JetBrains Mono with Nerd Font icons |
| nixfmt | package | Official Nix code formatter |
| nodejs | package | Node.js runtime and npm |
| obsidian | cask | Knowledge base and note-taking |
| ssh | module | SSH client config for GitLab and GitHub |
| starship | module | Cross-shell prompt with nerd font symbols |
| tfenv | brew | Terraform version manager |
| zoxide | module | Smarter cd that learns your habits |
| zsh | module | Shell with oh-my-zsh, autosuggestions, and fzf-tab |

## Launchd agents

Scheduled agents that run automatically:

| Agent | Schedule | Description |
| --- | --- | --- |
| mr-review-checker | Daily 08:00 | Queries GitLab MRs awaiting review and writes Obsidian checklist |
| meeting-minutes-processor | Hourly Mon-Fri 07:00-18:00 | Uses Quill MCP to extract meeting notes to Obsidian vault |
| obsidian-tagger | Daily 21:00 | Tags untagged markdown files in Obsidian vault |

All Claude-based agents run with restricted `--settings` scoped to only the tools and paths they need.

## Claude Code configuration

Claude Code is configured declaratively via `modules/home/development/claude.nix`:

- **Permission profiles** (`claude-permissions.nix`): Tiered allow/ask/deny lists (conservative, standard, autonomous) covering bash commands, MCP tools, and skills
- **Plugins**: Official Anthropic plugins and ITP engineering plugins (via flake inputs)
- **Status line**: Custom shell script showing directory, git branch, model, and context remaining

## Repo structure

```
flake.nix                        # Entry point, defines all machines and dev shell
lib/system/mk-darwin.nix         # Helper to wire nix-darwin + home-manager
systems/<arch>/<hostname>/       # Per-machine system config (homebrew, macOS defaults)
homes/<arch>/<user>@<hostname>/  # Per-machine home config (packages, imports, launchd agents)
modules/home/                    # Shared home-manager modules
.github/workflows/               # CI: flake check, formatting, weekly input updates
```

## Setup on a new machine

### 1. Install Nix

Install via [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) (recommended, it manages its own daemon):

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Clone this repo

```sh
git clone git@github.com:<your-user>/nix.git ~/Personal/nix
cd ~/Personal/nix
```

### 3. Add your machine config

Create system and home configs for the new machine. Use the existing `Finns-MacBook-Pro-8` as a template:

```sh
# Get your hostname
scutil --get LocalHostName

# Create system config
mkdir -p systems/aarch64-darwin/<hostname>
cp systems/aarch64-darwin/Finns-MacBook-Pro-8/default.nix systems/aarch64-darwin/<hostname>/default.nix
# Edit: update networking.hostName and system.primaryUser

# Create home config
mkdir -p homes/aarch64-darwin/<username>@<hostname>
cp homes/aarch64-darwin/finnjanssens@Finns-MacBook-Pro-8/default.nix homes/aarch64-darwin/<username>@<hostname>/default.nix
```

Add the new machine to `flake.nix`:

```nix
darwinConfigurations."<hostname>" = mkDarwin {
  system = "aarch64-darwin";
  username = "<username>";
  modules = [ ./systems/aarch64-darwin/<hostname> ];
  homeModules = [ "${self}/homes/aarch64-darwin/<username>@<hostname>" ];
};
```

### 4. Build and apply

```sh
sudo darwin-rebuild switch --flake .
```

On subsequent changes, run the same command to apply updates (alias: `drb`).

### 5. Enable direnv

```sh
direnv allow
```

### 6. Start container runtime

```sh
colima start
```

### 7. Store secrets in Keychain

Tokens are stored in macOS Keychain and read by shell config at runtime:

```sh
printf 'GitLab.com token: '
read -rs token
printf '\n'
security add-generic-password -a "$USER" -s "gitlab-com-pat" -w "$token" -U
unset token
printf 'git.inthepocket.org token: '
read -rs token
printf '\n'
security add-generic-password -a "$USER" -s "gitlab-itp-pat" -w "$token" -U
unset token
printf 'Context7 token: '
read -rs token
printf '\n'
security add-generic-password -a "$USER" -s "context7" -w "$token" -U
unset token
```

### 8. Authenticate glab CLI

```sh
glab auth login --hostname gitlab.com --token "$GITLAB_COM_PAT"
glab auth login --hostname git.inthepocket.org --token "$GITLAB_ITP_PAT"
```
