# default.nix (The actual final, correct version)
{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

let
  desktopItem = makeDesktopItem {
    name = "algermusicplayer";
    exec = "algermusicplayer-bin";
    icon = "algermusicplayer";
    comment = "An music player based on Electron, TypeScript, and Vue 3";
    desktopName = "AlgerMusicPlayer";
    genericName = "Music Player";
    categories = [
      "AudioVideo"
      "Audio"
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "AlgerMusicPlayer";
  version = "4.9.0";

  name = "algermusicplayer-bin-${version}";

  src =
    let
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
    in
    fetchurl (urls.${arch} or (throw "Unsupported system: ${arch}"));

  # nativeBuildInputs: 构建时使用的工具
  # 【最终修正】这里只包含真正的工具包，makeDesktopItem 已被移除
  nativeBuildInputs = [
    rpmextract
    makeWrapper
    autoPatchelfHook
  ];

  # buildInputs: 运行时需要的库
  buildInputs = [ electron ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    rpmextract $src

    install -d $out/bin $out/lib $out/share/applications $out/share/pixmaps

    cp -r opt/AlgerMusicPlayer $out/lib/algermusicplayer

    install -Dm644 usr/share/icons/hicolor/1084x1084/apps/algermusicplayer.png \
      $out/share/pixmaps/algermusicplayer.png

    makeWrapper $out/lib/algermusicplayer/algermusicplayer $out/bin/algermusicplayer-bin \
      --add-flags "--ozone-platform-hint=auto"

    # 我们使用由 let 块中的 makeDesktopItem 函数生成的 derivation 的输出
    cp ${desktopItem}/share/applications/* $out/share/applications/

    runHook postInstall
  '';

  passthru.updateScript = nix-update;

  meta = with lib; {
    description = "An music player based on Electron, TypeScript, and Vue 3";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = with maintainers; [ ];
  };
}
