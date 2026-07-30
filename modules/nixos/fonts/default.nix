{
  pkgs,
  ...
}:
let
  # PingFang OTF 字体（从 jimmyctk/PingFang-OTF-Fonts 拉取，避免将 Apple 专有字体提交进仓库）
  pingfang-src = pkgs.fetchFromGitHub {
    owner = "jimmyctk";
    repo = "PingFang-OTF-Fonts";
    rev = "b64166348f1248fd72ad1504c817af202cbfc1dd";
    hash = "sha256-DeZT802/7y939XT+upaFmEGlp6+vIgCpKbo12HEiGKc=";
  };

  pingfang = pkgs.runCommand "pingfang-font" { } ''
    mkdir -p $out/share/fonts/opentype
    cp ${pingfang-src}/OTF/*.otf $out/share/fonts/opentype/
  '';

  jetbrains-maple-mono = pkgs.callPackage ./jetbrains-maple-mono { };
in
{
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      # PingFang 优先，Noto 兜底；保证中文用苹方、其他语言 fallback 到 Noto
      defaultFonts = {
        sansSerif = [
          "PingFang SC"
          "PingFang TC"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans"
        ];
        serif = [
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif"
        ];
        monospace = [
          "Maple Mono NF"
          "JetBrains Mono"
          "Noto Sans Mono CJK SC"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
    packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.maple-mono.NF
      pkgs.jetbrains-mono
      jetbrains-maple-mono
      pingfang
    ];
  };
}
