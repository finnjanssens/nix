{ pkgs, inputs, ... }:
let
  starshipClaudeScript = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/martinemde/starship-claude/main/plugin/bin/starship-claude";
    hash = "sha256-ljd22LDZeEwdXhlaxHN60MY4VEQHBI22wwwhc86aNqY=";
  };

  starshipClaudeConfig = ../../../assets/starship-claude.toml;

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
