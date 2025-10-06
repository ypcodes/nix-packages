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
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # 1. 首先，从原始的、未修改的 nixpkgs 输入中创建一个 "pkgs" 实例。
        #    这里不应该有任何 overlays。这是一个干净的环境，专门用来构建你的包。
        pkgs = import nixpkgs {
          inherit system;
        };

        # 2. 在这里定义你所有的自定义包。
        #    把它们组织在一个属性集里，方便管理。
        myPackages = {
          algermusicplayer = pkgs.callPackage ./pkgs/algermusicplayer { };
          # 如果有其他包，可以加在这里:
          # another-package = pkgs.callPackage ./pkgs/another-package {};
        };

      in
      {
        # 3. 把你定义好的包暴露在 `packages` 属性下。
        #    这样别人就可以通过 `your-flake.packages.x86_64-linux.algermusicplayer` 来使用它。
        packages = myPackages;

        # 4. 现在，定义你想要“提供”给别人的 overlay。
        #    这个 overlay 的作用就是将 `myPackages` 里的所有包添加到 nixpkgs 里。
        overlays.default =
          final: prev:
          {
            # `final` 是应用此 overlay 后的最终 pkgs
            # `prev` 是应用此 overlay 之前的 pkgs

            # 将 myPackages 中的所有内容合并到最终的包集中
            # 这样别人用了你的 overlay 后，就可以直接通过 `pkgs.algermusicplayer` 来访问了。
          }
          // myPackages; # `//` 是 Nix 中合并两个属性集的语法

        # 5. 定义 defaultPackage，这样 `nix run .` 这样的命令才能工作。
        defaultPackage = myPackages.algermusicplayer;
      }
    );
}
