{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        extraOptions.UseKeychain = "yes";
      };

      "git.inthepocket.org" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab_itp";
      };

      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_personal";
      };

      "gitlab.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab";
      };
    };
  };
}
