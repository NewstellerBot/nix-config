{ ... }: {
  # Pinned declaratively so a Bonjour collision rename can't silently break
  # bare `darwin-rebuild switch --flake .` (it matches on LocalHostName).
  networking.hostName = "krystians-Work-MacBook-Pro";
  networking.localHostName = "krystians-Work-MacBook-Pro";
  networking.computerName = "Krystian's Work MacBook Pro";

  # Xcode, for the futre mobile app's iOS builds. Not in nixpkgs, so the Mac
  # App Store is the only declarative route. It lives here rather than in
  # modules/homebrew.nix because that module applies to both hosts — same
  # reasoning as doppler in home/work.nix.
  #
  # Needs to be recent enough to ship Swift >= 6.3: Expo SDK 57's
  # expo-modules-jsi declares `weak let`, which SE-0481 only implemented in
  # 6.3, so an older Xcode fails `expo run:ios` with "'weak' must be a mutable
  # variable" across 14 files. masApps always takes the App Store's current
  # version, so there is no pin to keep in step here.
  #
  # Requires an active Mac App Store sign-in — nix-darwin puts pkgs.mas on PATH
  # for `brew bundle` but cannot authenticate on your behalf.
  homebrew.masApps.Xcode = 497799835;
}
