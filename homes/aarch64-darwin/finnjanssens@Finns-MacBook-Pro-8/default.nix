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

  # Wallpaper
  home.activation.wallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.desktoppr}/bin/desktoppr ${../../../assets/wallpaper.jpg}
  '';

  # Daily Obsidian note tagger (runs at 21:00 local time)
  launchd.agents.obsidian-tagger = {
    enable = true;
    config = {
      ProgramArguments = [
        "/etc/profiles/per-user/finnjanssens/bin/claude"
        "--print"
        "--permission-mode"
        "acceptEdits"
        "--max-budget-usd"
        "0.50"
        "Find all markdown files that are missing YAML frontmatter tags. For each untagged note, read its content and add appropriate tags following the rules in CLAUDE.md. Report a summary of what was tagged."
      ];
      WorkingDirectory = "/Users/finnjanssens/Personal/obsidian";
      StartCalendarInterval = [
        {
          Hour = 21;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/obsidian-tagger.log";
      StandardErrorPath = "/tmp/obsidian-tagger.err";
    };
  };

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
