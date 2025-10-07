{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Login manager
    ./greetd.nix

    # File manager
    ./dolphin.nix
  ];

  # nixpkgs.overlays = [inputs.niri.overlays.niri];
  programs.niri = {
    enable = true;
    # package = pkgs.niri-unstable;
  };

  xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = "gtk";

  services.gnome.gnome-keyring.enable = true; # secret service

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    alacritty
    fuzzel
    # uwsm
  ];

  # NixOS 桌面配置 - Sway/Hyprland/Niri - 知乎
  # https://zhuanlan.zhihu.com/p/1914081913351681037

  # polkit agent
  systemd.user.services.niri-flake-polkit.enable = false;
  security.soteria.enable = true;

  # 磁盘挂载
  # services.gvfs.enable = true;

  # 压缩解压
  # programs.file-roller.enable = true;

  security.pam.services.swaylock = {};
}
