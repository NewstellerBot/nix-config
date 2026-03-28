{ pkgs, ... }: {
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

    # Build tools
    cmake
    ninja
    llvm

    # CLI tools
    ripgrep
    fd
    bat
    wget
    gh
    lazygit
    act
    cloc
    hyperfine
    ast-grep
    codex
    tmux
    neofetch

    # Infrastructure & cloud
    awscli2
    docker
    supabase-cli
    railway
    s3fs
    postgresql

    # Media & misc
    yt-dlp
    imagemagick
    qemu
    lz4
    e2fsprogs
    raylib
    hey

    # Debugging
    gdb

    # Python tooling
    uv

    # LSP servers (for Claude Code plugins)
    pyright
    nodePackages.typescript-language-server
    typescript
  ];
}
