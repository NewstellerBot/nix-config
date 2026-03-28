{ ... }: {
  programs.git = {
    enable = true;
    # Default identity: NewstellerBot
    userName = "NewstellerBot";
    userEmail = "kr21032002@icloud.com";
    delta.enable = true;
    lfs.enable = true;
    ignores = [ ".DS_Store" "*.swp" ".direnv" ];
    extraConfig = {
      core.editor = "nvim";
      credential."https://github.com".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
    # Switch to personal identity for futre repos
    includes = [
      {
        condition = "gitdir:~/code/futre/";
        contents = {
          user.name = "krystian-from-the-futre";
          user.email = "krystian@futre.me";
        };
      }
    ];
  };
}
