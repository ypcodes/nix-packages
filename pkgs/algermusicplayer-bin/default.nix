# default.nix (已修正)
{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

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

  nativeBuildInputs = [
    rpmextract
    makeWrapper
  ];
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
    # 使用更标准的图标路径
    install -d $out/share/icons/hicolor/1084x1084/apps

    # 安装应用核心文件
    install -Dm644 opt/AlgerMusicPlayer/resources/app.asar $out/lib/algermusicplayer/app.asar
    cp -r opt/AlgerMusicPlayer/resources/app.asar.unpacked $out/lib/algermusicplayer/
    cp -r opt/AlgerMusicPlayer/resources/html $out/lib/algermusicplayer/

    # 安装并修正 .desktop 文件
    install -Dm644 usr/share/applications/algermusicplayer.desktop $out/share/applications/algermusicplayer.desktop
    substituteInPlace $out/share/applications/algermusicplayer.desktop \
      # 【错误修正】Exec= 后面不应带有 Nix Store 的绝对路径
      --replace "Exec=algermusicplayer" "Exec=algermusicplayer-bin" \
      --replace "Categories=Audio;" "Categories=AudioVideo;" \
      # 同时更新图标路径（可选，但推荐）
      --replace "Icon=algermusicplayer" "Icon=algermusicplayer"

    # 安装图标到标准路径
    install -Dm644 usr/share/icons/hicolor/1084x1084/apps/algermusicplayer.png $out/share/icons/hicolor/1084x1084/apps/algermusicplayer.png

    # 创建启动脚本
    makeWrapper ${electron}/bin/electron $out/bin/algermusicplayer-bin \
      --add-flags $out/lib/algermusicplayer/app.asar \
      --add-flags "--ozone-platform-hint=auto"

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
