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
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    mkDarwin = import ./lib/system/mk-darwin.nix {
      inherit nixpkgs nix-darwin home-manager;
    };
  in
  {
    darwinConfigurations."Finns-MacBook-Pro-8" = mkDarwin {
      system = "aarch64-darwin";
      hostname = "Finns-MacBook-Pro-8";
      username = "finnjanssens";
      modules = [ ./systems/aarch64-darwin/Finns-MacBook-Pro-8 ];
      homeModules = [ "${self}/homes/aarch64-darwin/finnjanssens@Finns-MacBook-Pro-8" ];
    };
  };
}
