{
  config,
  lib,
  ...
}:
let
  desktop = config.pixdane.sukumizu.desktop;
in
{
  config = lib.mkIf (desktop == "niri-noctalia") {
    # === 启用共享 niri + noctalia 桌面配置 ===
    pixdane.desktop.niri.enable = true;
    pixdane.desktop.noctalia.enable = true;
    pixdane.desktop.greetd.enable = true;

    # === Intel iGPU ===
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # === NVIDIA PRIME Render Offload(Pascal GTX 1050 Mobile) ===
    # niri(Wayland)下 iGPU 负责显示输出,dGPU 仅按需渲染后回拷。
    # 与 kde-nvidia 的 prime.sync(X11-only)互斥;offload 兼容 Wayland。
    services.xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];
    # 注意:services.xserver.enable 保持 false(niri 不需要 Xorg server),
    # videoDrivers 仅作为触发 nixpkgs nvidia 模块的开关(惰性,不生成 xorg.conf)。

    hardware.nvidia = {
      open = false; # Pascal 无开源内核模块
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      modesetting.enable = true; # offload 会自动设 nvidia-drm.modeset=1,显式写出更清晰
      prime = {
        offload = {
          enable = true; # Wayland 兼容的 render offload(非 sync)
          enableOffloadCmd = true; # 生成 nvidia-offload wrapper
        };
        intelBusId = "PCI:0:2:0"; # lspci 0000:00:02.0
        nvidiaBusId = "PCI:1:0:0"; # lspci 0000:01:00.0
      };
      powerManagement.enable = true; # 挂起/恢复时保留 VRAM
      powerManagement.finegrained = false; # RTD3 在 Pascal 上不稳定,勿开
      nvidiaSettings = true;
    };

    # 纯 Wayland 下 nixpkgs 不会自动加载 nvidia 内核模块(仅 services.xserver.enable=true 时才加载),
    # 必须手动声明,否则 dGPU 无法被 offload 调用。
    boot.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
    ];
  };
}
