{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    swaybg
    waypaper
  ];

  programs.niri.package = pkgs.niri-unstable;

  # 根据不同的设备加载不同的显示器分辨率刷新率缩放
  # 就不用去 wm 里面一个一个配，导致每次换设备都要修改配置
  # https://wiki.archlinux.org/title/Kanshi
  services.kanshi.enable = true;

  services.mako.enable = true;

  programs.fuzzel.enable = true;

  services.swayidle.enable = true;

  # 夜光护眼软件
  services.wlsunset = {
    enable = true;
    sunset = "19:00";
    sunrise = "07:00";
  };

  # # 让大部分 gtk 软件选暗色主题
  # dconf = {
  #   settings = {
  #     "org/gnome/desktop/interface" = {
  #       color-scheme = "prefer-dark";
  #     };
  #   };
  # };

  programs.swaylock.enable = true;
}
