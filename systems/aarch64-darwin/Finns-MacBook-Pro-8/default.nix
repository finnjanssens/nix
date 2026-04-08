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
      "bruno"
      "ghostty"
    ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock = {
      tilesize = 27;
      magnification = true;
      largesize = 85;
      autohide = false;
      autohide-time-modifier = 0.15;
      mru-spaces = false;
      show-recents = false;
    };

    finder = {
      ShowStatusBar = true;
      FXDefaultSearchScope = "SCcf"; # search current folder by default
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      AppleScrollerPagingBehavior = true;
      "com.apple.trackpad.forceClick" = false;
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      target = "file";
    };

    WindowManager = {
      GloballyEnabled = false;
      HideDesktop = true;
      StandardHideDesktopIcons = false;
    };
  };

  system.stateVersion = 5;
}
