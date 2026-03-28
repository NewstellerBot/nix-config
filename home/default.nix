{ config, lib, pkgs, ... }: {
  imports = [ ./shell.nix ./git.nix ./tmux.nix ./direnv.nix ./claude.nix ./ghostty.nix ];

  home.stateVersion = "25.11";

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

}
