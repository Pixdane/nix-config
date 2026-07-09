{
  config,
  lib,
  ...
}:
let
  enabled = config.pixdane.features.direnv.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
