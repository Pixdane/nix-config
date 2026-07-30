{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.pixdane.desktop.greetd = {
    enable = lib.mkEnableOption "greetd display manager with niri autologin";
    user = lib.mkOption {
      type = lib.types.str;
      default = "pixdane";
      description = "User to autologin into the niri session.";
    };
  };

  config = lib.mkIf config.pixdane.desktop.greetd.enable {
    services.greetd = {
      enable = true;
      # tuigreet 是 TUI 界面的 greeter，需要 text greeter 设置
      useTextGreeter = true;
      settings = {
        # initial_session 在 greetd 首次启动时执行一次（自动登录）
        initial_session = {
          command = "niri-session";
          user = config.pixdane.desktop.greetd.user;
        };
        # default_session 是用户登出后执行的 greeter
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --remember --session niri";
        };
      };
    };
  };
}
