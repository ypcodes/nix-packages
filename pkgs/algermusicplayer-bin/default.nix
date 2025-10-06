# default.nix (Final, Patched Version)
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

  # 【修正 1】添加 autoPatchelfHook
  nativeBuildInputs = [
    rpmextract
    makeWrapper
    autoPatchelfHook
  ];

  # 【修正 2】添加运行时所需的共享库
  # 这是 autoPatchelfHook 查找 .so 文件的地方
  buildInputs = [
    alsa-lib
    at-spi2-atk
    cups
    dbus
    expat
    gcc.cc.lib # for libstdc++.so.6
    gdk-pixbuf
    glib
    gtk3
    nss
    pango
    pipewire
    systemd
    libxkbcommon
    # A common set of X11 libraries required by GUI apps
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXtst
  ];

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

    # 我们不再需要手动为可执行文件添加包装器了，
    # 因为 autoPatchelfHook 会处理它。
    # 但为了添加 flags，我们仍然保留 makeWrapper。
    # autoPatchelfHook 会在包装器创建 *之后* 再修补二进制文件，非常智能。
    makeWrapper $out/lib/algermusicplayer/algermusicplayer $out/bin/algermusicplayer-bin \
      --add-flags "--ozone-platform-hint=auto"

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
