{
  description = "A collection of Nix packages and overlays.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        myPackages = {
          algermusicplayer-bin = pkgs.callPackage ./pkgs/algermusicplayer-bin { };
          # 其他包...
        };

      in
      {
        # ✅ 最佳实践:
        # 将所有自定义包放在 `packages` 属性下。
        # 同时，定义一个名为 `default` 的特殊包，它指向你的默认包。
        packages = myPackages // {
        defaultPackage = myPackages.algermusicplayer-bin;
        };
      }
    ))
    // {
      overlays.default = final: prev: {
        algermusicplayer-bin = self.packages.${prev.system}.algermusicplayer-bin;
        # 其他包...
      };
    };
}
