{ config, lib, ... }:
let
  cfg = config.pixdane.darwin.ubersicht;
in
{
  options.pixdane.darwin.ubersicht.enable = lib.mkEnableOption "Ubersicht desktop widget host";

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "ubersicht"
    ];
  };
}
