{
  config,
  lib,
  ...
}:
let
  enabled = config.pixdane.features.starship.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.starship = {
      enable = true;

      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      presets = [
        "pure-preset"
      ];
    };
  };
}
