{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = config.pixdane.features.payRespects.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.pay-respects = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    home.packages = [
      pkgs.nix-search-cli
    ];
  };
}
