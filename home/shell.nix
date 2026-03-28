{ ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = { enable = true; theme = "robbyrussell"; plugins = [ "git" ]; };
    shellAliases = {
      sg = "ast-grep";
      cat = "bat";
      ccgo = "claude --dangerously-skip-permissions";
      codex = "codex --dangerously-bypass-approvals-and-sandbox";
      rebuild = "darwin-rebuild switch --flake /etc/nix-darwin";
    };
    sessionVariables = {
      EDITOR = "nvim";
      DISABLE_BUG_COMMAND = "1";
      DISABLE_ERROR_REPORTING = "1";
      DISABLE_TELEMETRY = "1";
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    };
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
  };
}
