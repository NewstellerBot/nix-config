{ ... }: {
  # Pinned declaratively so a Bonjour collision rename can't silently break
  # bare `darwin-rebuild switch --flake .` (it matches on LocalHostName).
  networking.hostName = "krystians-Work-MacBook-Pro";
  networking.localHostName = "krystians-Work-MacBook-Pro";
  networking.computerName = "Krystian's Work MacBook Pro";
}
