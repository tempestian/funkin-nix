{
  description = "Nix flake for Friday Night Funkin' (Linux port with Turkish story support)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = rec {
          funkin = pkgs.callPackage ./package.nix { withTurkish = false; };
          funkin-tr = pkgs.callPackage ./package.nix { withTurkish = true; };
          default = funkin;
        };

        apps = rec {
          funkin = flake-utils.lib.mkApp {
            drv = self.packages.${system}.funkin;
            name = "funkin";
          };
          funkin-tr = flake-utils.lib.mkApp {
            drv = self.packages.${system}.funkin-tr;
            name = "funkin";
          };
          default = funkin;
        };
      }
    ) // {
      overlays.default = final: prev: {
        funkin = final.callPackage ./package.nix { withTurkish = false; };
        funkin-tr = final.callPackage ./package.nix { withTurkish = true; };
      };
    };
}
