# default.nix
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation rec {
  pname = "AlgerMusicPlayer"; # 改为项目名，方便工具查找
  version = "4.9.0";

  # 最终的包名叫 algermusicplayer-bin
  # Nix 会自动将 pname 和 version 组合成 name (e.g., AlgerMusicPlayer-4.9.0)
  # 我们用 overrideAttrs 来设置最终的 pkg-name
  name = "algermusicplayer-bin-${version}";

  src = let
    arch = stdenv.hostPlatform.system;
    urls = {
      "x86_64-linux" = {
        url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/${pname}-${version}-linux-x86_64.rpm";
        sha256 = "268db69db376598cccbff8a714b6866aa0e0f28283ff00100156cf559714a186";
      };
      "aarch64-linux" = {
        url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/${pname}-${version}-linux-aarch64.rpm";
        sha256 = "fc298d5562ada6becc0102f3fd559d7400fcf9c80f4d81759e44841ed07673c4";
      };
    };
  in fetchurl (urls.${arch} or (throw "Unsupported system: ${arch}"));

  nativeBuildInputs = [ rpmextract makeWrapper ];
  buildInputs = [ electron ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    rpmextract $src
    install -d $out/bin $out/lib/algermusicplayer $out/share/applications $out/share/pixmaps
    install -Dm644 opt/AlgerMusicPlayer/resources/app.asar $out/lib/algermusicplayer/app.asar
    cp -r opt/AlgerMusicPlayer/resources/app.asar.unpacked $out/lib/algermusicplayer/
    cp -r opt/AlgerMusicPlayer/resources/html $out/lib/algermusicplayer/
    install -Dm644 usr/share/applications/algermusicplayer.desktop $out/share/applications/algermusicplayer.desktop
    install -Dm644 usr/share/icons/hicolor/1084x1084/apps/algermusicplayer.png $out/share/pixmaps/algermusicplayer.png
    substituteInPlace $out/share/applications/algermusicplayer.desktop \
      --replace "Exec=algermusicplayer" "Exec=$out/bin/algermusicplayer-bin" \
      --replace "Categories=Audio;" "Categories=AudioVideo;"
    makeWrapper ${electron}/bin/electron $out/bin/algermusicplayer-bin \
      --add-flags $out/lib/algermusicplayer/app.asar \
      --add-flags "--ozone-platform-hint=auto"
    runHook postInstall
  '';

  # passthru 允许我们给 derivation 添加额外的属性
  passthru.updateScript = nix-update;

  meta = with lib; {
    description = "An music player based on Electron, TypeScript, and Vue 3";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
