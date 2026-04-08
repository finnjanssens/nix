# CLAUDE.md

## Project overview

Declarative macOS setup using nix-darwin and home-manager. Manages both personal and work (In The Pocket) tooling. Intended to scale to multiple machines.

## Repo structure

- `flake.nix` -- entry point, defines all machines and dev shell
- `lib/system/mk-darwin.nix` -- helper to wire nix-darwin + home-manager
- `systems/<arch>/<hostname>/` -- per-machine system config (homebrew, macOS defaults, networking)
- `homes/<arch>/<user>@<hostname>/` -- per-machine home config (packages, module imports)
- `modules/home/` -- shared home-manager modules
- `scripts/` -- utility scripts (e.g. update-readme.sh)

## Nix conventions

- Use `nixpkgs-unstable` channel
- Use nixfmt for formatting (enforced via pre-commit hook)
- New `.nix` files must be `git add`ed before `darwin-rebuild` can see them (flake restriction)
- Keep one module per file in `modules/home/development/`
- Wire new modules in `modules/home/development/default.nix`

## Workflow

- After making changes, always verify by running `sudo darwin-rebuild switch --flake .` (alias: `drb`)
- New files need `git add` before rebuild
- The dev shell (`nix develop` / direnv) installs pre-commit hooks for nixfmt and secret detection
