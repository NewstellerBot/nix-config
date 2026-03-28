{ ... }: {
  system.defaults = {
    dock = {
      autohide = true;
      tilesize = 41;
      show-recents = false;
      mru-spaces = false;
      minimize-to-application = true;
      persistent-apps = [
        "/System/Applications/Launchpad.app"
        "/System/Applications/Messages.app"
        "/Applications/Ghostty.app"
        "/System/Applications/Calendar.app"
        "/Applications/Slack.app"
        "/Applications/Discord.app"
        "/Applications/Spotify.app"
        "/Applications/Helium Browser.app"
        "/Applications/Telegram.app"
      ];
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
    screencapture = {
      location = "~/Desktop/Screenshots";
      type = "png";
    };
    loginwindow.GuestEnabled = false;
  };
}
