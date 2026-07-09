{
  config,
  lib,
  ...
}:
let
  enabled = config.pixdane.features.nixYourShell.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.nix-your-shell = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
