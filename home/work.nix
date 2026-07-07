# Work machine: slack/linear plugins (each bundles its own MCP server) plus
# standalone MCP servers. Linear MCP comes from the plugin — no separate server.
{
  imports = [ ./default.nix ];

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
