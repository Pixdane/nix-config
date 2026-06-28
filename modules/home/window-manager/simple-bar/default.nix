{
  config,
  inputs,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  enabled = osConfig != null && (osConfig.pixdane.darwin.windowManager.bar or "none") == "simple-bar";

  patchedSimpleBar = pkgs.stdenvNoCC.mkDerivation {
    pname = "simple-bar";
    version = "7673cbbc56973748897bcae15afc135865694351";

    nativeBuildInputs = [
      pkgs.perl
    ];

    src = inputs.simple-bar;

    patches = [
      ./patches/local-current.patch
    ];

    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R . "$out"/
      chmod -R u+w "$out"
      while IFS= read -r -d "" file; do
        if LC_ALL=C grep -Iq . "$file"; then
          perl -0pi -e 's/(?<!\r)\n/\r\n/g' "$file"
        fi
      done < <(find "$out" -type f -print0)
      while IFS= read -r -d "" file; do
        perl -0pi -e 's/\r\n/\n/g' "$file"
      done < <(find "$out/lib/scripts" -type f -print0)
      runHook postInstall
    '';
  };
in
{
  config = lib.mkIf enabled {
    home.file."Library/Application Support/Übersicht/widgets/simple-bar" = {
      source = patchedSimpleBar;
      recursive = true;
      force = true;
    };

    home.file.".simplebarrc".source = ./simplebarrc.json;
  };
}
