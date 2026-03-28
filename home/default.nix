{ config, lib, pkgs, ... }: {
  imports = [ ./shell.nix ./git.nix ./tmux.nix ./direnv.nix ./claude.nix ./ghostty.nix ];

  home.stateVersion = "25.11";

  # Use symlinks instead of rsync for ~/Applications (copyApps has permission bugs)
  targets.darwin.linkApps.enable = true;

  # Nvim: nix store symlink (read-only — packer_compiled.lua redirected to ~/.local/share/nvim/)
  home.file.".config/nvim".source = ../configs/nvim;

  # Packer: installed via nixpkgs, placed in opt dir — run :PackerSync manually on first open
  home.file.".local/share/nvim/site/pack/packer/opt/packer.nvim".source =
    pkgs.vimPlugins.packer-nvim;

  # Undo directory for persistent undo history
  home.file.".vim/undodir/.keep".text = "";

  # Karabiner: copy (not symlink) — Karabiner destroys symlinks on every config save
  # GUI changes are lost on next rebuild; copy them back to the repo to persist
  home.activation.karabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/karabiner"
    cp -f ${../configs/karabiner/karabiner.json} "$HOME/.config/karabiner/karabiner.json"
    chmod 644 "$HOME/.config/karabiner/karabiner.json"
    /bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/org.pqrs.karabiner.karabiner_console_user_server 2>/dev/null || true
  '';

}
