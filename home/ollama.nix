{ lib, pkgs, ... }: {
  # Ollama: downloaded directly from source to avoid version lag
  # The macOS app auto-updates itself after initial install
  home.activation.ollama = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Ollama.app" ]; then
      export PATH="${pkgs.curl}/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
      OLLAMA_TMP=$(mktemp -d)
      curl -fsSL -o "$OLLAMA_TMP/Ollama-darwin.zip" "https://ollama.com/download/Ollama-darwin.zip"
      /usr/bin/unzip -qo "$OLLAMA_TMP/Ollama-darwin.zip" -d /Applications
      rm -rf "$OLLAMA_TMP"
    fi
    mkdir -p "$HOME/.local/bin"
    ln -sf /Applications/Ollama.app/Contents/Resources/ollama "$HOME/.local/bin/ollama"
  '';
}
