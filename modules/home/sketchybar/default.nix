{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  programs.sketchybar = {
    enable = true;
    config = {
      source = ./config;
      recursive = true;
    };
    service.enable = true;
  };
}
