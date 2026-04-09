{ pkgs, lib, ... }:
{
  imports = [
    ../../../modules/home/development
  ];

  home.stateVersion = "24.11";

  # Menu bar spacing (notch fix: fits more icons in visible area)
  # Uses -currentHost so it must run as the user, not root (hence home-manager, not nix-darwin)
  home.activation.menuBarSpacing = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD /usr/bin/defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 8
    $DRY_RUN_CMD /usr/bin/defaults -currentHost write -globalDomain NSStatusItemSpacing -int 12
  '';

  # CLI on PATH via Home Manager profile (avoids relying on Homebrew/npm global paths)
  home.packages = [
    pkgs.nixfmt
    pkgs.colima
    pkgs.docker-client
    pkgs.lazydocker
    pkgs.glab
    pkgs.awscli2
    pkgs.go
    pkgs.nodejs
    pkgs.delta
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
