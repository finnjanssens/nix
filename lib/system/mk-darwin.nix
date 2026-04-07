{
  nixpkgs,
  nix-darwin,
  home-manager,
}:
{
  system,
  hostname,
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
        manual.manpages.enable = false;
      };
    }
  ];
}
