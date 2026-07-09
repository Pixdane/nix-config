{
  config,
  lib,
  ...
}:
let
  enabled = config.pixdane.features.zellij.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
