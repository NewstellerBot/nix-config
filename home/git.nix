{ ... }: {
  programs.git = {
    enable = true;
    ignores = [ ".DS_Store" "*.swp" ".direnv" ];
    lfs.enable = true;
    settings = {
      user = {
        name = "NewstellerBot";
        email = "kr21032002@icloud.com";
      };
      core.editor = "nvim";
      credential."https://github.com".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
