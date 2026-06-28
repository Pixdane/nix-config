{ config, lib, ... }:
{
  config = lib.mkIf (config.pixdane.darwin.windowManager.bar == "simple-bar") {
    pixdane.darwin.ubersicht.enable = lib.mkDefault true;
  };
}
