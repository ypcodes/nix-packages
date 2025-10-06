
{
  description = "A collection of Nix packages and overlays.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        packages.algermusicplayer = pkgs.callPackage ./pkgs/algermusicplayer {};
        defaultPackage = pkgs.algermusicplayer;
      }
    );
}
