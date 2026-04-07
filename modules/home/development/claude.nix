{ pkgs, ... }:
let
  statuslineScript = pkgs.writeShellScript "claude-statusline" ''
    input=$(cat)

    cwd=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir // .cwd')
    model=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.model.display_name // ""')
    remaining=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.remaining_percentage // empty')

    # Shorten home directory to ~
    home="$HOME"
    short_cwd="''${cwd/#$home/~}"

    # Git info (skip optional locks)
    git_branch=""
    git_status_symbol=""
    if git_branch_raw=$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null); then
      git_branch="$git_branch_raw"
      if [ -n "$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
        git_status_symbol="✗"
        git_status_color="\033[0;33m"  # yellow
      else
        git_status_symbol="✓"
        git_status_color="\033[0;32m"  # green
      fi
    fi

    # Build status line
    cyan="\033[0;36m"
    bold_blue="\033[1;34m"
    bold_red="\033[0;31m"
    reset="\033[0m"
    dim="\033[2m"

    line=""

    # Directory
    line+="$(printf "''${cyan}%s''${reset}" "$short_cwd")"

    # Git info
    if [ -n "$git_branch" ]; then
      line+=" $(printf "''${bold_blue}(''${bold_red}%s''${bold_blue})''${reset} ''${git_status_color}%s''${reset}" "$git_branch" "$git_status_symbol")"
    fi

    # Model
    if [ -n "$model" ]; then
      line+=" $(printf "''${dim}[%s]''${reset}" "$model")"
    fi

    # Context remaining
    if [ -n "$remaining" ]; then
      remaining_int=''${remaining%.*}
      if [ "$remaining_int" -le 20 ]; then
        ctx_color="\033[0;31m"  # red when low
      elif [ "$remaining_int" -le 50 ]; then
        ctx_color="\033[0;33m"  # yellow when medium
      else
        ctx_color="\033[0;32m"  # green when plenty
      fi
      line+=" $(printf "''${ctx_color}ctx:%s%%''${reset}" "$remaining_int")"
    fi

    printf "%b\n" "$line"
  '';

  settings = {
    prefersReducedMotion = true;
    statusLine = {
      type = "command";
      command = "${statuslineScript}";
    };

    enabledPlugins = {
      "itp-engineering-backend@inthepocket" = true;
      "itp-engineering-daikin@inthepocket" = true;
      "itp-engineering@inthepocket" = true;
      "itp-general@inthepocket" = true;
      "itp-utils@inthepocket" = true;
      "security-guidance@claude-plugins-official" = true;
      "superpowers@claude-plugins-official" = true;
    };

    extraKnownMarketplaces = {
      inthepocket = {
        source = {
          source = "git";
          url = "git@git.inthepocket.org:inthepocket/skills/marketplace.git";
        };
      };
    };
  };
in
{
  home.file.".claude/settings.json".text = builtins.toJSON settings;
}
