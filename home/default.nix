{ config, lib, pkgs, ... }: {
  imports = [ ./shell.nix ./git.nix ./tmux.nix ./direnv.nix ./claude.nix ];

  home.stateVersion = "24.11";

  # Nvim: nix store symlink (read-only — packer_compiled.lua redirected to ~/.local/share/nvim/)
  home.file.".config/nvim".source = ../configs/nvim;

  # Packer: installed via nixpkgs, placed in opt dir — run :PackerSync manually on first open
  home.file.".local/share/nvim/site/pack/packer/opt/packer.nvim".source =
    pkgs.vimPlugins.packer-nvim;

  # Undo directory for persistent undo history
  home.file.".vim/undodir/.keep".text = "";

  # Karabiner: mutable symlink (GUI needs write access to save config changes)
  home.file.".config/karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nix-darwin/configs/karabiner";

  # Dock apps via dockutil — Finder is always pinned by macOS
  home.activation.configureDock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dock="${pkgs.dockutil}/bin/dockutil"
    $dock --remove all --no-restart
    $dock --add /System/Applications/Launchpad.app --no-restart
    $dock --add /System/Applications/Messages.app --no-restart
    $dock --add /Applications/Ghostty.app --no-restart
    $dock --add /System/Applications/Calendar.app --no-restart
    $dock --add /Applications/Slack.app --no-restart
    $dock --add /Applications/Discord.app --no-restart
    $dock --add /Applications/Spotify.app --no-restart
    $dock --add "/Applications/Helium Browser.app" --no-restart
    $dock --add /Applications/Telegram.app
  '';
}
