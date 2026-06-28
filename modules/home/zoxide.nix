{
  config,
  lib,
  ...
}:
let
  enabled = config.pixdane.features.zoxide.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
