{ ... }: {
  power.sleep.display = 15;
  system.defaults = {
    dock = {
      autohide = true;
      tilesize = 41;
      show-recents = false;
      mru-spaces = false;
      minimize-to-application = true;
      persistent-apps = [
        "/System/Applications/Mail.app"
        "/System/Applications/Apps.app"
        "/System/Applications/Messages.app"
        "/Applications/Ghostty.app"
        "/System/Applications/Calendar.app"
        "/Applications/Slack.app"
        "/Applications/Discord.app"
        "/Applications/Spotify.app"
        "/Applications/Helium.app"
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
      Clicking = false;
      TrackpadThreeFingerDrag = false;
    };
    screencapture = {
      location = "~/Desktop/Screenshots";
      type = "png";
    };
    loginwindow.GuestEnabled = false;
  };

  system.defaults.CustomUserPreferences = {
    "net.imput.helium" = {
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "Google";
      DefaultSearchProviderSearchURL = "https://google.com/search?q={searchTerms}";
      DefaultSearchProviderSuggestURL = "https://google.com/complete/search?client=chrome&q={searchTerms}";
      HomepageLocation = "https://news.ycombinator.com";
      HomepageIsNewTabPage = false;
    };
  };
}
