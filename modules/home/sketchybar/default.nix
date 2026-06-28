{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  warnings = [
    "homeModules.sketchybar is deprecated and kept only as an unmigrated legacy snapshot. It is not part of the first full-rework feature set; use pixdane.darwin.windowManager.bar = \"simple-bar\" for the current bar setup."
  ];

  programs.sketchybar = {
    enable = false;
    config = {
      source = ./config;
      recursive = true;
    };
    service.enable = true;
  };
}
