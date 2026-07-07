{ config, lib, pkgs, ... }:
let
  cfg = config.my.claude;

  # Plugins installed on every host; hosts add more via my.claude.extraPlugins.
  basePlugins = [
    "pyright-lsp@claude-plugins-official"
    "typescript-lsp@claude-plugins-official"
    "rust-analyzer-lsp@claude-plugins-official"
    "clangd-lsp@claude-plugins-official"
  ];
  activePlugins = basePlugins ++ cfg.extraPlugins;

  # Every plugin managed on ANY host. Excluded ones get an explicit `false` in
  # enabledPlugins so a previously-installed plugin is disabled, not left on.
  # When a host gains a new plugin, add its name here too.
  allKnownPlugins = basePlugins ++ [
    "slack@claude-plugins-official"
    "linear@claude-plugins-official"
  ];

  # Every MCP server name ever managed on ANY host. All are removed before the
  # declared ones are re-added, so a host that drops a server converges.
  # When a host gains a new server, add its name here too.
  managedMcpNames = [ "figma" "playwright" ];

  pluginInstalls = lib.concatMapStrings (plugin:
    "$claude plugin install ${lib.escapeShellArg plugin} 2>/dev/null || true\n"
  ) activePlugins;

  mcpRemoves = lib.concatMapStrings (name:
    "$claude mcp remove -s user ${lib.escapeShellArg name} 2>/dev/null || true\n"
  ) managedMcpNames;

  mcpAdds = lib.concatStrings (lib.mapAttrsToList (name: server:
    if server.transport == "http" then
      "$claude mcp add -s user --transport http ${lib.escapeShellArg name} ${lib.escapeShellArg server.url} 2>/dev/null || true\n"
    else
      "$claude mcp add -s user ${lib.escapeShellArg name} -- ${lib.escapeShellArgs ([ server.command ] ++ server.args)} 2>/dev/null || true\n"
  ) cfg.mcpServers);
in
{
  options.my.claude = {
    mcpServers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          transport = lib.mkOption {
            type = lib.types.enum [ "http" "stdio" ];
            default = "http";
          };
          url = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Endpoint for http transport.";
          };
          command = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Executable for stdio transport.";
          };
          args = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Arguments for stdio transport.";
          };
        };
      });
      default = { };
      description = "User-scope Claude Code MCP servers for this host.";
    };

    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Claude Code plugins for this host, on top of the shared LSP plugins.";
    };
  };

  config = {
    assertions = lib.mapAttrsToList (name: server: {
      assertion =
        if server.transport == "http" then server.url != null else server.command != null;
      message = "my.claude.mcpServers.${name}: ${server.transport} transport requires ${
        if server.transport == "http" then "url" else "command"}";
    }) cfg.mcpServers;

    # User-scope CLAUDE.md — loaded for every Claude Code session.
    # Counters a few Claude 4.7 defaults (brevity bias, "attempt now, don't interview").
    home.file.".claude/CLAUDE.md".text = ''
# Reasoning

Think carefully and step-by-step before responding; assume the problem is harder than it looks. Prioritize correctness and maintainability over brevity. Verify APIs and package names by researching online against documentation rather than guessing. If you don't know something, say so and search — don't assume. If a request is ambiguous, ask before acting.

# Researching

When researching try using industry blog posts, reddit, and research papers rather than shallow marketing websites. We want to know what actual people use, say, etc rather than what companies promise.
    '';

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
      model = "claude-fable-5[1m]";
      # model = "claude-opus-4-8[1m]";
      effortLevel = "xhigh";
      # ultracode = true;
      includeCoAuthoredBy = false;
      skipDangerousModePermissionPrompt = true;
      enabledPlugins = lib.genAttrs allKnownPlugins (p: lib.elem p activePlugins);
    };

    # Install Claude Code via native installer (auto-updates in background)
    # Then install plugins and sync MCP servers — all idempotent
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

      ${pluginInstalls}
      # MCP servers — remove all managed names, re-add the declared ones
      # (picks up URL changes; user scope writes to ~/.claude.json)
      ${mcpRemoves}
      ${mcpAdds}
      # Restore the Nix store symlink (enabledPlugins is declared in settings.json)
      rm -f "$settings"
      ln -s "$target" "$settings"
    '';
  };
}
