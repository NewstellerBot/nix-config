{
  description = "krystian's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, homebrew-core, homebrew-cask, ... }:
  {
    darwinConfigurations."krystians-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self; };
      modules = [
        # Temporary overlay: fix direnv build on darwin (nixpkgs-unstable regression)
        # Remove once nixpkgs-unstable includes PR #502769
        {
          nixpkgs.overlays = [
            (final: prev: {
              direnv = prev.direnv.overrideAttrs (old: {
                postPatch = (old.postPatch or "") + ''
                  substituteInPlace GNUmakefile --replace-fail " -linkmode=external" ""
                '';
              });
            })
          ];
        }

        ./hosts/krystians-MacBook-Pro.nix
        ./modules/packages.nix
        ./modules/homebrew.nix
        ./modules/system.nix
        ./modules/security.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.users.krystian = import ./home;
        }

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "krystian";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
        }
      ];
    };
  };
}
