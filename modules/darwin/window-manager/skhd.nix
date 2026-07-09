{ config, lib, ... }:
let
  cfg = config.pixdane.darwin.skhd;
in
{
  options.pixdane.darwin.skhd.enable = lib.mkEnableOption "skhd hotkey daemon";

  config = lib.mkIf cfg.enable {
    services.skhd.enable = true;
  };
}
