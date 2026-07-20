# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build / apply

Two-host nix-darwin flake (both aarch64-darwin): `krystians-MacBook-Pro` (personal) and `krystians-Work-MacBook-Pro` (work).

```sh
sudo darwin-rebuild switch --flake .  # picks the host matching `scutil --get LocalHostName`; activation must run as root
nix flake update                 # bump all inputs
nix flake check                  # evaluate without building
```

First rebuild on a machine whose hostname doesn't match yet needs the explicit attribute, e.g. `sudo darwin-rebuild switch --flake .#krystians-Work-MacBook-Pro`; activation sets the hostname, so bare `--flake .` works from then on.

There are no tests or linters configured.

## Architecture

`flake.nix` composes each `darwinConfigurations` entry via the `mkHost` helper from three layers:

- `hosts/common.nix` — shared host identity (platform, primary user, state version). `hosts/personal.nix` / `hosts/work.nix` — per-machine hostnames (`networking.*`), pinned declaratively so Bonjour collision renames can't break hostname-based flake resolution.
- `modules/*.nix` — system-level nix-darwin modules (`packages.nix`, `homebrew.nix`, `system.nix`, `security.nix`). All four are imported unconditionally for every host.
- `home/` — home-manager modules. Per-host entry points `home/personal.nix` / `home/work.nix` are thin wrappers that import `home/default.nix` (which imports the rest: `shell.nix`, `git.nix`, `tmux.nix`, `direnv.nix`, `claude.nix`, `codex.nix`, `ghostty.nix`) and set `my.claude.*` options — personal gets no MCP servers and only LSP plugins; work adds slack/linear plugins, figma/playwright MCP servers, the Doppler CLI (`pkgs.doppler`; nixpkgs, not the brew tap, so it stays work-only — `doppler update` can't self-update the read-only nix binary, use `nix flake update`), the `ticket-loop` Claude skill (sourced from `configs/claude/skills/`), and the `wt` worktree helper (`configs/bin/wt.py`, installed to `~/.local/bin/wt` with a nix-pinned python3 shebang; creates `~/.worktrees/<repo>/<branch>`, copies the root `.env`, runs `pnpm install` + `pnpm sync-env`).

`nix-homebrew` is wired in `flake.nix` with `mutableTaps = false` — taps are pinned to the `homebrew-core` / `homebrew-cask` flake inputs, not the system's brew state.

Raw config files live in `configs/` (currently `nvim/` and `karabiner/`) and are sourced by `home/default.nix`, not managed as nix expressions.

## Non-obvious footguns

These are coded as workarounds; understand them before editing:

- **Karabiner config** is *copied* (not symlinked) in a `home.activation` block — Karabiner destroys symlinks on every GUI save. Consequence: GUI changes to Karabiner are **lost** on next `darwin-rebuild`. Copy `~/.config/karabiner/karabiner.json` back into `configs/karabiner/` to persist.
- **Neovim config** is a read-only Nix store symlink. `packer_compiled.lua` is redirected to `~/.local/share/nvim/`. Packer itself is installed to the `opt/` pack dir — run `:PackerSync` manually on first open.
- **Claude Code** is installed via the upstream `claude.ai/install.sh` script, not nixpkgs (auto-updates in background). `home/claude.nix` writes `~/.claude/settings.json` as a Nix store symlink, then the activation script temporarily swaps it for a writable copy so `claude plugin install` can write cache, then restores the symlink. Don't "simplify" this — `claude plugin install` fails on a read-only symlink.
- **Per-host Claude MCPs/plugins** come from the `my.claude.mcpServers` / `my.claude.extraPlugins` options (declared in `home/claude.nix`, set in `home/work.nix`). The activation script removes every server in `managedMcpNames` before re-adding the declared ones, so hosts that drop a server converge — when adding a new MCP server or plugin on any host, also append its name to `managedMcpNames` / `allKnownPlugins` in `home/claude.nix` so the other host removes/disables it.
- **Codex CLI** is installed via `npm install -g @openai/codex` in `home/codex.nix`, not nixpkgs or Homebrew. The activation script installs into `~/.local/bin` so Codex can track npm releases rather than lagging package repos.
- **direnv overlay** in `flake.nix` patches out a Go linker flag to fix a nixpkgs-unstable regression. Remove the overlay once nixpkgs PR #502769 lands.
- `home-manager.backupFileExtension = "hm-backup"` — conflicting existing files get renamed instead of failing the activation.
