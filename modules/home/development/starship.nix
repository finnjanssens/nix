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
    gcloud.disabled = true;
    aws.format = "on [$symbol$profile ]($style)";
  };
}
