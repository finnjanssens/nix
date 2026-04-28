{
  description = "Finn's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };
    claude-plugin-itp-general = {
      url = "git+ssh://git@git.inthepocket.org/inthepocket/skills/general.git";
      flake = false;
    };
    claude-plugin-itp-engineering = {
      url = "git+ssh://git@git.inthepocket.org/inthepocket/skills/engineering/engineering.git";
      flake = false;
    };
    claude-plugin-itp-engineering-backend = {
      url = "git+ssh://git@git.inthepocket.org/inthepocket/skills/engineering/backend.git";
      flake = false;
    };
    claude-plugin-itp-engineering-daikin = {
      url = "git+ssh://git@git.inthepocket.org/inthepocket/skills/engineering/daikin.git";
      flake = false;
    };
    claude-plugin-itp-utils = {
      url = "git+ssh://git@git.inthepocket.org/inthepocket/skills/utils.git";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      git-hooks,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      mkDarwin = import ./lib/system/mk-darwin.nix {
        inherit nixpkgs nix-darwin home-manager;
      };

      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks.nixfmt.enable = true;
        hooks.detect-private-keys.enable = true;
        hooks.detect-aws-credentials.enable = true;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = pre-commit-check.enabledPackages;
        shellHook = pre-commit-check.shellHook;
      };

      darwinConfigurations."Finns-MacBook-Pro-8" = mkDarwin {
        inherit inputs;
        system = "aarch64-darwin";
        username = "finnjanssens";
        modules = [ ./systems/aarch64-darwin/Finns-MacBook-Pro-8 ];
        homeModules = [ "${self}/homes/aarch64-darwin/finnjanssens@Finns-MacBook-Pro-8" ];
      };
    };
}
