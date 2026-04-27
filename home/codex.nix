{ lib, pkgs, ... }: {
  # Codex CLI: install from npm so it can track upstream releases directly.
  home.activation.codex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.nodejs}/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

    prefix="$HOME/.local"
    codex="$prefix/bin/codex"

    mkdir -p "$prefix/bin"
    export NPM_CONFIG_PREFIX="$prefix"

    if [ ! -x "$codex" ]; then
      run npm install -g @openai/codex
    else
      npm install -g @openai/codex >/dev/null 2>&1 || true
    fi
  '';
}
