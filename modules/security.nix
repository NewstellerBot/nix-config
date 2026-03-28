{ ... }: {
  security.pam.services.sudo_local.touchIdAuth = true;
  programs.zsh.enableCompletion = false;
}
