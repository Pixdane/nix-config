{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pixdane.system.helix;
in
{
  options.pixdane.system.helix.enable = lib.mkEnableOption "Helix as the system editor";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      inputs.helix-flake.packages.${pkgs.system}.default
    ];

    environment.variables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
  };
}
