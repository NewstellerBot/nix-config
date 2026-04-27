# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build / apply

Single-host nix-darwin flake. The only host is `krystians-MacBook-Pro` (aarch64-darwin).

```sh
darwin-rebuild switch --flake .#krystians-MacBook-Pro
nix flake update                 # bump all inputs
nix flake check                  # evaluate without building
```

There are no tests or linters configured.

## Architecture

`flake.nix` composes one `darwinConfigurations` entry from three layers:

- `hosts/krystians-MacBook-Pro.nix` — host identity (platform, primary user, state version). Edit here for per-machine values.
- `modules/*.nix` — system-level nix-darwin modules (`packages.nix`, `homebrew.nix`, `system.nix`, `security.nix`). All four are imported unconditionally from `flake.nix`.
- `home/` — home-manager modules. `home/default.nix` is the entry point and imports the rest (`shell.nix`, `git.nix`, `tmux.nix`, `direnv.nix`, `claude.nix`, `codex.nix`, `ghostty.nix`).

`nix-homebrew` is wired in `flake.nix` with `mutableTaps = false` — taps are pinned to the `homebrew-core` / `homebrew-cask` flake inputs, not the system's brew state.

Raw config files live in `configs/` (currently `nvim/` and `karabiner/`) and are sourced by `home/default.nix`, not managed as nix expressions.

## Non-obvious footguns

These are coded as workarounds; understand them before editing:

- **Karabiner config** is *copied* (not symlinked) in a `home.activation` block — Karabiner destroys symlinks on every GUI save. Consequence: GUI changes to Karabiner are **lost** on next `darwin-rebuild`. Copy `~/.config/karabiner/karabiner.json` back into `configs/karabiner/` to persist.
- **Neovim config** is a read-only Nix store symlink. `packer_compiled.lua` is redirected to `~/.local/share/nvim/`. Packer itself is installed to the `opt/` pack dir — run `:PackerSync` manually on first open.
- **Claude Code** is installed via the upstream `claude.ai/install.sh` script, not nixpkgs (auto-updates in background). `home/claude.nix` writes `~/.claude/settings.json` as a Nix store symlink, then the activation script temporarily swaps it for a writable copy so `claude plugin install` can write cache, then restores the symlink. Don't "simplify" this — `claude plugin install` fails on a read-only symlink.
- **Codex CLI** is installed via `npm install -g @openai/codex` in `home/codex.nix`, not nixpkgs or Homebrew. The activation script installs into `~/.local/bin` so Codex can track npm releases rather than lagging package repos.
- **direnv overlay** in `flake.nix` patches out a Go linker flag to fix a nixpkgs-unstable regression. Remove the overlay once nixpkgs PR #502769 lands.
- `home-manager.backupFileExtension = "hm-backup"` — conflicting existing files get renamed instead of failing the activation.
