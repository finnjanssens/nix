{ config, pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height=40%" "--layout=reverse" "--border" ];
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
      path = "${config.home.homeDirectory}/.zsh_history";
    };

    sessionVariables = {
      COMPLETION_WAITING_DOTS = "true";
      HIST_STAMPS = "%d/%m/%y %T";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "aws"
        "git"
        "colorize"
        "npm"
        "yarn"
        "history"
        "httpie"
      ];
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    initContent = ''
      export GITLAB_COM_TOKEN=$(security find-generic-password -s "gitlab-pat" -a "$USER" -w 2>/dev/null)
    '';

    shellAliases = {
      drb = "sudo darwin-rebuild switch --flake ~/.config/nix";
      owc = "git aa && git commit --amend --no-edit && git push --force-with-lease";
      tf = "terraform";
      g = "git";
      ave = "aws-vault exec";
    };

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
