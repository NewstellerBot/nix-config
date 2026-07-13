# Work machine: slack/linear plugins (each bundles its own MCP server) plus
# standalone MCP servers. Linear MCP comes from the plugin — no separate server.
{
  imports = [ ./default.nix ];

  # Work-only Claude Code skill: /ticket-loop orchestrates implement-ticket →
  # PR → fresh-session review rounds. Depends on the futre repo's project
  # skills, so it stays off the personal host.
  home.file.".claude/skills/ticket-loop/SKILL.md".source =
    ../configs/claude/skills/ticket-loop/SKILL.md;

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
