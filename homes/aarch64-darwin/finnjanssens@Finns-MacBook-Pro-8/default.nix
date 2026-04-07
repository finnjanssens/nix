{ pkgs, ... }:
{
  imports = [
    ../../../modules/home/development
  ];

  home.stateVersion = "24.11";

  # CLI on PATH via Home Manager profile (avoids relying on Homebrew/npm global paths)
  home.packages = [
    pkgs.nixfmt
    pkgs.claude-code
    pkgs.glab
    pkgs.awscli2
    pkgs.go
    pkgs.nodejs
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
