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
  };

  # Install Claude Code via native installer (auto-updates in background)
  # Then install LSP plugins — all idempotent
  home.activation.claudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "$HOME/.local/bin/claude" ]; then
      PATH="${pkgs.curl}/bin:/usr/bin:/bin:$PATH" run ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | PATH="${pkgs.curl}/bin:/usr/bin:/bin:$PATH" ${pkgs.bash}/bin/bash
    fi

    claude="$HOME/.local/bin/claude"
    $claude plugin install pyright-lsp@claude-plugins-official 2>/dev/null || true
    $claude plugin install typescript-lsp@claude-plugins-official 2>/dev/null || true
    $claude plugin install rust-analyzer-lsp@claude-plugins-official 2>/dev/null || true
    $claude plugin install clangd-lsp@claude-plugins-official 2>/dev/null || true
  '';
}
