{
  fetchzip,
  runCommand,
}:
let
  src = fetchzip {
    url = "https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases/download/1.2304.79/JetBrainsMapleMono-NF-XX-XX-XX.zip";
    hash = "sha256-V8hLVGbADfzN0eaUUVoLYj/aN3TSCwWhNWDEpbC6wVY=";
    stripRoot = false;
  };
in
runCommand "jetbrains-maple-mono" { } ''
  mkdir -p $out/share/fonts/truetype
  cp ${src}/*.ttf $out/share/fonts/truetype/
''
