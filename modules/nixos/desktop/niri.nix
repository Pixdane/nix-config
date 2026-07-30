{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.pixdane.desktop.niri = {
    enable = lib.mkEnableOption "niri Wayland compositor";
  };

  config = lib.mkIf config.pixdane.desktop.niri.enable {
    programs.niri.enable = true;

    # niri 官方推荐 xwayland-satellite 提供 Xwayland 兼容
    environment.systemPackages = [ pkgs.xwayland-satellite ];

    xdg.portal.config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ]; # or "kde"
    };
  };
}
