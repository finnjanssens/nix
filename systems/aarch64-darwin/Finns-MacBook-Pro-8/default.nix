{ ... }:
{
  networking.hostName = "Finns-MacBook-Pro-8";
  system.primaryUser = "finnjanssens";

  # Determinate Systems Nix manages its own daemon — disable nix-darwin's Nix management
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    taps = [
      "atlassian/acli"
    ];
    brews = [
      "atlassian/acli/acli"
      "tfenv"
    ];
    casks = [
      "aws-vault-binary"
      "ghostty"
    ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;
}
