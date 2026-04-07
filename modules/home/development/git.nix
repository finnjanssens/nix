{ ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user.name = "Finn Janssens";
      user.email = "finn.janssens@inthepocket.com";

      alias = {
        a = "add";
        aa = "add --all";
        c = "commit -m";
        p = "push";
        br = "branch";
        cp = "cherry-pick";
        nbr = "!f() { git checkout -b $1 && git push --set-upstream origin $1; }; f";
        st = "status";
        co = "checkout";
        pu = "pull";
        f = "fetch";
        psuo = "push --set-upstream origin";
      };

      color.ui = "auto";
      color.branch = {
        current = "yellow bold";
        local = "green bold";
        remote = "cyan bold";
      };
      color.diff = {
        meta = "yellow bold";
        frag = "magenta bold";
        old = "red bold";
        new = "green bold";
        whitespace = "red reverse";
      };
      color.status = {
        added = "green bold";
        changed = "yellow bold";
        untracked = "red bold";
      };

      pull.rebase = true;
      rebase = {
        autosquash = true;
        autoStash = true;
      };
      push.autoSetupRemote = true;
      fetch.prune = true;
      core.autocrlf = "input";
    };

    # Adopt new default (was "openpgp" before home.stateVersion 25.05)
    signing.format = null;

    ignores = [
      ".DS_Store"
      ".direnv"
      ".envrc"
      ".pre-commit-config.yaml"
    ];
  };
}
