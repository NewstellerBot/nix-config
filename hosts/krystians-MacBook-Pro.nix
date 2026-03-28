{ self, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  system.primaryUser = "krystian";
  nix.settings.experimental-features = "nix-command flakes";
}
