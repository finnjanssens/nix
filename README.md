# Finn's Nix Config

Declarative macOS setup using [nix-darwin](https://github.com/LnL7/nix-darwin) and [Home Manager](https://github.com/nix-community/home-manager).

## What's managed

- **System** (nix-darwin) -- Homebrew taps/casks/brews, Touch ID sudo, networking
- **Home** (Home Manager) -- zsh, neovim, git, ghostty, starship, fzf, ssh, Claude Code
- **Packages** -- nixfmt-tree, claude-code, glab, awscli2, JetBrains Mono Nerd Font, tfenv, aws-vault

## Repo structure

```
flake.nix                        # Entry point -- defines all machines
lib/system/mk-darwin.nix         # Helper to wire nix-darwin + home-manager
systems/<arch>/<hostname>/       # Per-machine system config (homebrew, networking)
homes/<arch>/<user>@<hostname>/  # Per-machine home config (packages, imports)
modules/home/                    # Shared home-manager modules
```

## Setup on a new machine

### 1. Install Nix

Install via [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) (recommended -- it manages its own daemon):

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
  hostname = "<hostname>";
  username = "<username>";
  modules = [ ./systems/aarch64-darwin/<hostname> ];
  homeModules = [ "${self}/homes/aarch64-darwin/<username>@<hostname>" ];
};
```

### 4. Build and apply

```sh
sudo darwin-rebuild switch --flake .
```

On subsequent changes, run the same command to apply updates.

### 5. Store secrets in Keychain

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

### 6. Authenticate glab CLI

```sh
glab auth login --hostname gitlab.com --token "$GITLAB_COM_PAT"
glab auth login --hostname git.inthepocket.org --token "$GITLAB_ITP_PAT"
```
