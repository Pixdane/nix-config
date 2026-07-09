{ config, lib, ... }:
let
  enabled = config.pixdane.features.helix.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.helix.themes = {
      catppuccin_mocha_modified = builtins.fromTOML (
        builtins.readFile ./themes/catppuccin_mocha_modified.toml
      );
    };
  };
}
