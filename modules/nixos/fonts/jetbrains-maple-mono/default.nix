{
  fetchzip,
  runCommand,
}:
let
  src = fetchzip {
    url = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases/download/1.2304.79/JetBrainsMapleMono-NF-XX-XX-XX.zip";
    hash = "sha256-SPw1OeUXSuO6N6+XFkvJ4F6JGQRn5V7hBxhax+b8bgs=";
    stripRoot = false;
  };
in
runCommand "jetbrains-maple-mono" { } ''
  mkdir -p $out/share/fonts/truetype
  cp ${src}/*.ttf $out/share/fonts/truetype/
''
