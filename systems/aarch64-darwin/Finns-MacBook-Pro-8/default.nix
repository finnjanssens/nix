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
      "arc"
      "obsidian"
    ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock = {
      tilesize = 24;
      magnification = true;
      largesize = 85;
      autohide = false;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.3;
      mineffect = "scale";
      mru-spaces = false;
      show-recents = false;
      enable-spring-load-actions-on-all-items = true;
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
      ApplePressAndHoldEnabled = false;
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
