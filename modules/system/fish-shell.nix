{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pixdane.system.fishShell;
in
{
  options.pixdane.system.fishShell.enable = lib.mkEnableOption "system fish shell support";

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;

    environment.shells = lib.mkIf pkgs.stdenv.isDarwin [
      pkgs.fish
    ];
  };
}
