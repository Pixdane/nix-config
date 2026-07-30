{
  config,
  lib,
  pkgs,
  inputs,
  ...

}:

let
  cfg = config.pixdane.system.flatpak;

  # 国内 Flathub 镜像(二选一,均为动态缓存/代理模式):
  #   USTC : https://mirrors.ustc.edu.cn/flathub
  #   SJTUG: https://mirrors.sjtug.sjtu.edu.cn/flathub
  # 注意:TUNA 不提供 Flathub 镜像。
  flathubMirror = "https://mirrors.ustc.edu.cn/flathub";

  # Flathub 官方 GPG key（镜像不提供 .flatpakrepo，需手动导入 key 做签名校验）
  flathubGpgKey = pkgs.fetchurl {
    url = "https://flathub.org/repo/flathub.gpg";
    hash = "sha256-i9wgq8ThnAeWRgvrW/4OeqQThxaZnhnG8tvdeMxBrqo=";
  };
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.pixdane.system.flatpak = {
    enable = lib.mkEnableOption "Flatpak with Flathub (mirrored) and declarative package management";

    packages = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
      description = ''
        Flatpak apps to install declaratively via nix-flatpak.
        Accepts either a plain app-id string (e.g. "com.spotify.Client")
        or an attrset: { appId = "..."; origin = "flathub"; }.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. 启用 Flatpak(NixOS 原生模块)
    services.flatpak.enable = true;

    # 2. XDG Desktop Portal(flatpak 模块的必要依赖)
    #    不强制指定默认后端:由各桌面环境模块自行决定
    #    (plasma6 会设为 kde,GNOME 会设为 gtk),此处仅确保 enable + 保留 gtk 作后备。
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    environment.variables.GTK_USE_PORTAL = "1";

    # 3. 配置 Flathub remote + 声明安装的包(nix-flatpak)
    #    直接使用国内镜像 URL，并通过 gpg-import 导入官方 GPG key 做签名校验。
    #    remote-add 在 managed-install 之前执行，首次安装即走镜像。
    services.flatpak = {
      remotes = [
        {
          name = "flathub";
          location = flathubMirror;
          gpg-import = "${flathubGpgKey}";
        }
      ];

      packages = cfg.packages;

      update = {
        onActivation = true; # 每次 nixos-rebuild switch 时同步安装/更新
        auto = {
          enable = true;
          onCalendar = "weekly"; # systemd timer,每周自动更新
        };
      };

      uninstallUnmanaged = false; # 保留手动安装的包,避免误删
    };
  };
}
