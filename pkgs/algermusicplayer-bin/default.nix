# default.nix (最终健壮版)
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation rec {
  pname = "AlgerMusicPlayer";
  version = "4.9.0";

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

    # 创建必要的目录
    install -d $out/bin $out/lib/algermusicplayer
    install -d $out/share/applications
    install -d $out/share/icons/hicolor/1084x1084/apps

    # 安装应用核心文件
    install -Dm644 opt/AlgerMusicPlayer/resources/app.asar $out/lib/algermusicplayer/app.asar
    cp -r opt/AlgerMusicPlayer/resources/app.asar.unpacked $out/lib/algermusicplayer/
    cp -r opt/AlgerMusicPlayer/resources/html $out/lib/algermusicplayer/
    
    # 安装图标到标准路径
    install -Dm644 usr/share/icons/hicolor/1084x1084/apps/algermusicplayer.png $out/share/icons/hicolor/1084x1084/apps/algermusicplayer.png

    # 创建启动脚本
    makeWrapper ${electron}/bin/electron $out/bin/algermusicplayer-bin \
      --add-flags $out/lib/algermusicplayer/app.asar \
      --add-flags "--ozone-platform-hint=auto"

    # 【推荐的健壮做法】直接创建我们自己的 .desktop 文件，而不是修改原始文件。
    # 这样可以确保内容完全符合我们的预期，不受上游变动的影响。
    cat <<EOF > $out/share/applications/algermusicplayer.desktop
    [Desktop Entry]
    Name=AlgerMusicPlayer
    Comment=${meta.description}
    Exec=algermusicplayer-bin
    Icon=algermusicplayer
    Terminal=false
    Type=Application
    Categories=AudioVideo;Audio;
    EOF

    runHook postInstall
  '';

  passthru.updateScript = nix-update;

  meta = with lib; {
    description = "An music player based on Electron, TypeScript, and Vue 3";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
