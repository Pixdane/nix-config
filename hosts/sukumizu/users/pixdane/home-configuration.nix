{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.self.homeModules.base ];

  pixdane.features.enabled = [
    "fish"
    "git"
    "helix"
    "starship"
    "direnv"
    "zoxide"
    "nixYourShell"
    "payRespects"
    "tools"
    "wezterm"
  ];

  # 全局鼠标指针主题：同步 GTK / dconf / XDG 环境变量
  home.pointerCursor = {
    enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.plasma-systemmonitor
    playerctl # Media control
    vscode-fhs
    jetbrains.idea
    opencode
  ] ++ [
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.openchamber
  ];

  # niri / noctalia 配置使用 mkOutOfStoreSymlink 直接指向仓库源文件
  # 修改后无需 rebuild，即时生效（适合调试阶段）
  xdg.configFile."niri" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/hosts/sukumizu/users/pixdane/config/niri";
    recursive = true;
  };
  xdg.configFile."noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/hosts/sukumizu/users/pixdane/config/noctalia";
    recursive = true;
  };
}
