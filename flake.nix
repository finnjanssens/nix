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
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      git-hooks,
      ...
    }:
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
        system = "aarch64-darwin";
        hostname = "Finns-MacBook-Pro-8";
        username = "finnjanssens";
        modules = [ ./systems/aarch64-darwin/Finns-MacBook-Pro-8 ];
        homeModules = [ "${self}/homes/aarch64-darwin/finnjanssens@Finns-MacBook-Pro-8" ];
      };
    };
}
