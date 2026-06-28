{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = config.pixdane.features.tools.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    home.packages =
      with pkgs;
      [
        xz
        zstd
        jq
        fd
        ripgrep
        ncdu
        yazi
        lazygit
        ouch
        nixfmt
        nixd
        cachix
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        dos2unix
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        zip
        unzip
      ];
  };
}
