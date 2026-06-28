{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = config.pixdane.features.helix.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.helix.languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
  };
}
