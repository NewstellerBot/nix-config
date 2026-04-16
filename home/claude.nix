{ lib, pkgs, ... }: {
  # Claude Code settings (installed via native installer, not nixpkgs)
  home.file.".claude/settings.json".text = builtins.toJSON {
    permissions = {
      allow = [
        "Bash(git *)"
        "Read"
        "Glob"
        "Grep"
      ];
    };
    model = "claude-opus-4-7[1m]";
    effortLevel = "max";
    includeCoAuthoredBy = false;
    skipDangerousModePermissionPrompt = true;
    enabledPlugins = {
      "pyright-lsp@claude-plugins-official" = true;
      "typescript-lsp@claude-plugins-official" = true;
      "rust-analyzer-lsp@claude-plugins-official" = true;
      "clangd-lsp@claude-plugins-official" = true;
      "slack@claude-plugins-official" = true;
      "linear@claude-plugins-official" = true;
    };
  };

  # Install Claude Code via native installer (auto-updates in background)
  # Then install LSP plugins — all idempotent
  home.activation.claudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "$HOME/.local/bin/claude" ]; then
      export PATH="${pkgs.curl}/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
      run curl -fsSL https://claude.ai/install.sh | bash
    fi

    claude="$HOME/.local/bin/claude"

    # settings.json is a read-only Nix store symlink — temporarily replace
    # it with a writable copy so `claude plugin install` can download plugin
    # files to cache. home-manager will restore the symlink on next activation.
    settings="$HOME/.claude/settings.json"
    if [ -L "$settings" ]; then
      target=$(readlink "$settings")
      rm "$settings"
      cp "$target" "$settings"
    fi

    $claude plugin install pyright-lsp@claude-plugins-official 2>/dev/null || true
    $claude plugin install typescript-lsp@claude-plugins-official 2>/dev/null || true
    $claude plugin install rust-analyzer-lsp@claude-plugins-official 2>/dev/null || true
    $claude plugin install clangd-lsp@claude-plugins-official 2>/dev/null || true
    $claude plugin install slack@claude-plugins-official 2>/dev/null || true
    $claude plugin install linear@claude-plugins-official 2>/dev/null || true

    # MCP servers — re-add to pick up URL changes (user scope writes to ~/.claude.json)
    $claude mcp remove -s user figma 2>/dev/null || true
    $claude mcp add -s user --transport http figma http://127.0.0.1:3845/mcp 2>/dev/null || true

    # Restore the Nix store symlink (enabledPlugins is declared in settings.json)
    rm -f "$settings"
    ln -s "$target" "$settings"
  '';
}
