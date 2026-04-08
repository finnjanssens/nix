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
}:

nix-darwin.lib.darwinSystem {
  inherit system;
  modules = modules ++ [
    home-manager.darwinModules.home-manager
    {
      users.users.${username}.home = "/Users/${username}";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${username} = {
        imports = homeModules;
        manual.manpages.enable = false; # speeds up home-manager builds
      };
    }
  ];
}
