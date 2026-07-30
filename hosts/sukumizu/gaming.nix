{
  pkgs,
  ...
}:

{
  # === Steam(nixpkgs 模块,32 位运行时 + Proton + udev + 防火墙一体化) ===
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Steam Remote Play 穿透防火墙
    dedicatedServer.openFirewall = true; # 专用服务器穿透防火墙
    localNetworkGameTransfers.openFirewall = true; # 局域网联机传输穿透防火墙
    extraCompatPackages = [ pkgs.proton-ge-bin ]; # Proton GE 兼容层
    protontricks.enable = true; # 游戏存档/前缀管理工具
    extest.enable = true; # X11->uinput 事件翻译,niri(Wayland)+Xwayland 下让 Steam Input 正常工作
    package = pkgs.steam.override { extraEnv.MANGOHUD = true; }; # 注入 Mangohud 环境变量
  };

  programs.gamemode.enable = true; # GameMode CPU/GPU 性能优化
  programs.gamescope.enable = true; # Gamescope 微合成器(兼容层/性能隔离)

  # === 蓝牙(DualSense 手柄配对) ===
  # noctalia.recommendedServices 已启用蓝牙服务,此处显式补充 DualSense 防断连设置。
  hardware.bluetooth.settings.General.IdleTimeout = 0; # 防止手柄约 10 分钟无操作自动断连

  environment.systemPackages = with pkgs; [
    dualsensectl # DualSense CLI:灯条颜色/扳机效果/电量查询
    evtest # 测试 /dev/input/event* 原始事件
    mangohud # FPS/性能叠层(MANGOHUD=1 %command% 或已通过 steam.override 注入)
  ];
}
