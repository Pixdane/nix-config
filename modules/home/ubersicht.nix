{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  enabled = osConfig != null && (osConfig.pixdane.darwin.ubersicht.enable or false);
in
{
  config = lib.mkIf enabled {
    home.file.".config/ubersicht".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Übersicht";
  };
}
