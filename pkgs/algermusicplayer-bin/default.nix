# default.nix (Final Corrected Version)
{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

let
  # 使用 pkgs.writeText 创建一个 .desktop 文件内容
  # 这样做比在 installPhase 里用 cat <<EOF 更清晰
  desktopItem = makeDesktopItem {
    name = "algermusicplayer"; # .desktop 文件的名字
    exec = "algermusicplayer-bin"; # 我们创建的包装器的名字
    icon = "algermusicplayer"; # 图标的名字（不带后缀），系统会自动在 pixmaps 等目录寻找
    comment = "An music player based on Electron, TypeScript, and Vue 3";
    desktopName = "AlgerMusicPlayer"; # 显示在菜单里的名字
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

  # nativeBuildInputs 包含了构建时需要的工具
  nativeBuildInputs = [
    rpmextract
    makeWrapper
    makeDesktopItem
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    rpmextract $src

    # 1. 创建目标目录
    install -d $out/bin $out/lib $out/share/applications $out/share/pixmaps

    # 2. 将整个应用目录复制过来
    cp -r opt/AlgerMusicPlayer $out/lib/algermusicplayer

    # 3. 安装图标到标准位置
    install -Dm644 usr/share/icons/hicolor/1084x1084/apps/algermusicplayer.png \
      $out/share/pixmaps/algermusicplayer.png

    # 4. 【关键修正】包装应用自带的可执行文件
    makeWrapper $out/lib/algermusicplayer/algermusicplayer $out/bin/algermusicplayer-bin \
      --add-flags "--ozone-platform-hint=auto"

    # 5. 【关键修正】创建我们自己的、路径正确的 .desktop 文件
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
