{
  nixpkgs,
  nix-darwin,
  home-manager,
}:
{
  system,
  username,
  modules,
  homeModules,
  inputs ? { },
}:

nix-darwin.lib.darwinSystem {
  inherit system;
  modules = modules ++ [
    {
      nixpkgs.overlays = [
        (_final: prev: {
          # direnv's checkPhase intermittently hangs on macOS; skip it.
          direnv = prev.direnv.overrideAttrs (_old: {
            doCheck = false;
          });
        })
      ];
    }
    home-manager.darwinModules.home-manager
    {
      users.users.${username}.home = "/Users/${username}";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.${username} = {
        imports = homeModules;
        manual.manpages.enable = false; # speeds up home-manager builds
      };
    }
  ];
}
