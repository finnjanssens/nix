{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  starshipClaudeScript = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/martinemde/starship-claude/main/plugin/bin/starship-claude";
    hash = "sha256-ljd22LDZeEwdXhlaxHN60MY4VEQHBI22wwwhc86aNqY=";
  };

  starshipClaudeSettings = lib.recursiveUpdate (import ./starship-common.nix) {
    "$schema" = "https://starship.rs/config-schema.json";
    add_newline = false;
    format = lib.concatStrings [
      "$directory"
      "$git_branch"
      "$git_status"
      "$nix_shell"
      "\${env_var.CLAUDE_MODEL_NERD}"
      "\${env_var.CLAUDE_CONTEXT}"
      "\${env_var.CLAUDE_COST}"
    ];
    directory = {
      style = "bold cyan";
      format = "[$path]($style) ";
      truncation_length = 2;
      truncate_to_repo = true;
      read_only = " RO";
    };
    git_branch = {
      symbol = "";
      style = "bold purple";
      format = "on [$symbol$branch]($style) ";
    };
    git_status = {
      style = "bold red";
      format = "[\\[$all_status$ahead_behind\\]]($style) ";
    };
    nix_shell = {
      symbol = "";
      style = "bold blue";
      format = "via [$symbol$state \\($name\\)]($style) ";
    };
    env_var.CLAUDE_MODEL_NERD = {
      variable = "CLAUDE_MODEL_NERD";
      format = "[$env_value]($style) ";
      style = "dimmed white";
    };
    env_var.CLAUDE_CONTEXT = {
      variable = "CLAUDE_CONTEXT";
      format = "[$env_value]($style) ";
      style = "green";
    };
    env_var.CLAUDE_COST = {
      variable = "CLAUDE_COST";
      format = "[$env_value]($style)";
      style = "dimmed white";
    };
  };

  starshipClaudeConfig =
    (pkgs.formats.toml { }).generate "starship-claude.toml"
      starshipClaudeSettings;

  starshipClaude = pkgs.writeShellScript "starship-claude-wrapper" ''
    export PATH="${pkgs.starship}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin:${pkgs.git}/bin:$PATH"
    exec ${pkgs.bash}/bin/bash ${starshipClaudeScript} --config ${starshipClaudeConfig} "$@"
  '';
in
{
  imports = [ ./claude-permissions.nix ];

  programs.claude-code = {
    enable = true;

    plugins = [
      "${inputs.claude-plugins-official}/plugins/security-guidance"
      "${inputs.claude-plugins-official}/plugins/superpowers"
      inputs.claude-plugin-itp-general
      inputs.claude-plugin-itp-engineering
      inputs.claude-plugin-itp-engineering-backend
      inputs.claude-plugin-itp-engineering-daikin
      inputs.claude-plugin-itp-utils
      "/Users/finnjanssens/ITP/skills/engineering/daikin"
    ];

    context = builtins.readFile ../../../assets/claude-context.md;

    skills = {
      obsidian-vault = ./skills/obsidian-vault/SKILL.md;
      my-reviews = ./skills/my-reviews/SKILL.md;
      tone-of-voice = ./skills/tone-of-voice/SKILL.md;
    };

    settings = {
      prefersReducedMotion = true;
      statusLine = {
        type = "command";
        command = "${starshipClaude}";
      };
      permissions = {
        additionalDirectories = [ "~/Personal/obsidian" ];
      };
    };
  };
}
