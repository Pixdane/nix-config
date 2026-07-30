{
  config,
  lib,
  ...
}:
let
  desktop = config.pixdane.sukumizu.desktop;
in
{
  config = lib.mkIf (desktop == "kde-nvidia") {
    # === 启用共享 KDE 桌面配置 ===
    pixdane.desktop.kde.enable = true;

    # PRIME sync 仅限 X11：覆盖共享模块的默认值
    services.displayManager.sddm.wayland.enable = false;
    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # === NVIDIA Pascal GTX 1050 Mobile (PRIME sync) ===
    hardware.nvidia = {
      modesetting.enable = true;
      open = false; # Pascal 不支持开源内核模块
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

      prime = {
        sync.enable = true; # Pascal 唯一可用模式（仅 X11）
        intelBusId = "PCI:0:2:0"; # lspci 0000:00:02.0
        nvidiaBusId = "PCI:1:0:0"; # lspci 0000:01:00.0
      };

      powerManagement.enable = true; # 挂起时保留 VRAM
      nvidiaSettings = true;
    };
  };
}
