# Work machine: slack/linear plugins (each bundles its own MCP server) plus
# standalone MCP servers. Linear MCP comes from the plugin — no separate server.
{ pkgs, ... }: {
  imports = [ ./default.nix ];

  # Work-only Claude Code skill: /ticket-loop orchestrates implement-ticket →
  # PR → fresh-session review rounds. Depends on the futre repo's project
  # skills and the `wt` helper below, so it stays off the personal host.
  home.file.".claude/skills/ticket-loop/SKILL.md".source =
    ../configs/claude/skills/ticket-loop/SKILL.md;

  # `wt` worktree helper: creates ~/.worktrees/<repo>/<branch>, copies the root
  # .env into it, then runs pnpm install + pnpm sync-env (futre's per-package
  # env distributor) so worktrees start with working env vars. Installed into
  # ~/.local/bin (front of PATH). Shebang is pinned to the nix python3 because
  # the script needs 3.10+ (`X | None` annotations) and Apple ships 3.9.
  home.file.".local/bin/wt" = {
    text = "#!${pkgs.python3}/bin/python3\n" + builtins.readFile ../configs/bin/wt.py;
    executable = true;
  };

  my.claude = {
    extraPlugins = [
      "slack@claude-plugins-official"
      "linear@claude-plugins-official"
    ];
    mcpServers = {
      figma = {
        transport = "http";
        url = "http://127.0.0.1:3845/mcp";
      };
      # Playwright, not the archived @modelcontextprotocol/server-puppeteer
      # (deprecated upstream, unpatched SSRF advisory)
      playwright = {
        transport = "stdio";
        command = "npx";
        args = [ "-y" "@playwright/mcp@latest" ];
      };
    };
  };
}
