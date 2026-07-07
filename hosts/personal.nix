{ ... }: {
  # Pinned declaratively so a Bonjour collision rename can't silently break
  # bare `darwin-rebuild switch --flake .` (it matches on LocalHostName).
  networking.hostName = "krystians-MacBook-Pro";
  networking.localHostName = "krystians-MacBook-Pro";
  networking.computerName = "Krystian's MacBook Pro";
}
