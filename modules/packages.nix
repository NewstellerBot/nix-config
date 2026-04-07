{ pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim

    # Languages & runtimes
    python3
    nodejs
    pnpm
    bun
    go
    rustup
    zig

    # CLI tools
    ripgrep
    fd
    bat
    wget
    gh
    lazygit
    cloc
    hyperfine
    ast-grep
    codex
    tmux
    fastfetch

    # Google Workspace CLI
    inputs.google-workspace-cli.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Infrastructure & cloud
    awscli2
    docker
    railway
    postgresql

    # Media & misc
    yt-dlp
    imagemagick
    qemu
    hey

    # Treesitter (needed by nvim-treesitter to build parsers)
    tree-sitter

    # Python tooling
    uv

    # LSP servers (for Claude Code plugins)
    pyright
    nodePackages.typescript-language-server
    typescript
  ];
}
