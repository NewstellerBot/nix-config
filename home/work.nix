# Work machine: slack/linear plugins (each bundles its own MCP server) plus
# standalone MCP servers. Linear MCP comes from the plugin — no separate server.
{ config, pkgs, ... }: {
  imports = [ ./default.nix ];

  # Work-only Claude Code skill: /ticket-loop orchestrates implement-ticket →
  # PR → fresh-session review rounds. Depends on the futre repo's project
  # skills and the `wt` helper below, so it stays off the personal host.
  home.file.".claude/skills/ticket-loop/SKILL.md".source =
    ../configs/claude/skills/ticket-loop/SKILL.md;

  # /pr-writeup fills a draft PR's description from the repo template, in my voice,
  # grounded only in what was actually done. ticket-loop calls it before exit.
  home.file.".claude/skills/pr-writeup/SKILL.md".source =
    ../configs/claude/skills/pr-writeup/SKILL.md;

  # `wt` worktree helper: creates ~/.worktrees/<repo>/<branch>, copies the root
  # .env into it, then runs pnpm install + pnpm sync-env (futre's per-package
  # env distributor) so worktrees start with working env vars. Installed into
  # ~/.local/bin (front of PATH). Shebang is pinned to the nix python3 because
  # the script needs 3.10+ (`X | None` annotations) and Apple ships 3.9.
  home.file.".local/bin/wt" = {
    text = "#!${pkgs.python3}/bin/python3\n" + builtins.readFile ../configs/bin/wt.py;
    executable = true;
  };

  # Doppler CLI (work secrets manager). From nixpkgs, not the dopplerhq/cli
  # brew tap — taps are pinned via nix-homebrew (mutableTaps = false) and
  # homebrew.nix applies to both hosts, so brew would leak this to personal.
  # The nix binary is read-only, so `doppler update` can't self-update;
  # updates come from `nix flake update` like everything else.
  #
  # CocoaPods: `expo run:ios` shells out to `pod install` when building the
  # futre mobile app's native project. Work-only for the same reason as
  # doppler above.
  #
  # android-tools: adb and fastboot. Android Studio ships its own copies under
  # ~/Library/Android/sdk/platform-tools, which is not on PATH; this puts them
  # there without depending on where Studio put its SDK.
  home.packages = [ pkgs.doppler pkgs.cocoapods pkgs.android-tools ];

  # `expo run:android` resolves the SDK through ANDROID_HOME. This is Studio's
  # default SDK location — set after installing it, so it exists before anything
  # reads this. JAVA_HOME is deliberately not set here: Studio's bundled
  # JetBrains Runtime is the only JDK on this machine, and its path moves
  # between Studio versions, so point it at the real one once and revisit if
  # Gradle stops finding a JDK.
  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/Library/Android/sdk";
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
      # Sentry hosted MCP (OAuth — authenticate once via /mcp in Claude Code)
      sentry = {
        transport = "http";
        url = "https://mcp.sentry.dev/mcp";
      };
    };
  };
}
