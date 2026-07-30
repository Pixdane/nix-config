{
  lib,
  config,
  ...
}:
{
  options.pixdane.desktop.kde = {
    enable = lib.mkEnableOption "KDE Plasma 6 desktop environment";
  };

  config = lib.mkIf config.pixdane.desktop.kde.enable {
    services.displayManager.sddm = {
      enable = true;
      # Wayland 默认开启；如需 X11(例如 NVIDIA PRIME sync)由调用方关闭。
      wayland.enable = lib.mkDefault true;
    };
    services.desktopManager.plasma6.enable = true;

    # X11 默认不启用；需要 X11 的场景(如 NVIDIA PRIME sync)由调用方开启。
    services.xserver.enable = lib.mkDefault false;
  };
}
