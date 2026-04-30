{ lib, ... }:
let
  shared = import ./starship-common.nix;
in
{
  programs.starship.enable = true;

  programs.starship.presets = [
    "nerd-font-symbols"
  ];

  programs.starship.settings = lib.recursiveUpdate shared {
    # Symbol overrides
    aws.symbol = "  ";

    # Custom settings
    cmd_duration.disabled = true;
    gcloud.disabled = true;
    aws.format = "on [$symbol$profile ]($style)";
    nodejs.disabled = true;
    git_commit.tag_disabled = false;
  };
}
