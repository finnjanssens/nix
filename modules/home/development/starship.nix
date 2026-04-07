{ ... }:
{
  programs.starship.enable = true;

  programs.starship.presets = [
    "nerd-font-symbols"
  ];

  programs.starship.settings = {
    # Symbol overrides
    aws.symbol = "  ";

    # Custom settings
    cmd_duration.disabled = true;
    gcloud.disabled = true;
    aws.format = "on [$symbol$profile ]($style)";
  };
}
