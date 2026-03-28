{ ... }: {
  homebrew = {
    enable = true;
    casks = [
      "balenaetcher"
      "beekeeper-studio"
      "discord"
      "ghostty"
      "google-chrome"
      "helium-browser"
      "karabiner-elements"
      "macfuse"
      "nordvpn"
      "orbstack"
      "slack"
      "spotify"
      "steam"
      "telegram"
      "transmission"
      "virtualdj"
      "visual-studio-code"
    ];
    brews = [
      "autoconf"
      "autoconf-archive"
      "automake"
      "librealsense"
      "pkg-config"
      "qt"
    ];
  };
}
