{ ... }: {
  programs.ghostty = {
    enable = true;
    package = null; # installed via homebrew cask
    enableZshIntegration = true;
    settings = {
      cursor-style = "block";
      cursor-style-blink = true;
      keybind = "shift+enter=text:\\n";
      theme = "Oxocarbon";
      background-opacity = 0.85;
      font-family = "Berkeley Mono";
      shell-integration-features = "ssh-env,no-cursor";
    };
  };
}
