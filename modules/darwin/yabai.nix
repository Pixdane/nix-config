{ config, lib, ... }:
let
  cfg = config.pixdane.darwin.windowManager;

  commonConfig = {
    # global settings
    mouse_follows_focus = "off";
    focus_follows_mouse = "off";
    window_origin_display = "default";
    window_topmost = "off";
    window_shadow = "on";
    window_opacity = "off";
    window_opacity_duration = 2000.0;
    active_window_opacity = 1.0;
    normal_window_opacity = 0.85;
    window_border = "off";
    window_border_width = 6;
    active_window_border_color = "0xff775759";
    normal_window_border_color = "0xff555555";
    insert_feedback_color = "0xffd75f5f";
    split_ratio = 0.50;
    auto_balance = "off";
    mouse_modifier = "fn";
    mouse_action1 = "move";
    mouse_action2 = "resize";
    mouse_drop_action = "swap";

    # general space settings
    layout = "bsp";
    top_padding = 4;
    left_padding = 4;
    right_padding = 4;
    window_gap = 4;
  };

  barPadding = {
    none = {
      bottom_padding = 4;
    };
    simple-bar = {
      bottom_padding = 44;
    };
  };

  unmanagedAppRules = lib.concatMapStringsSep "\n" (
    app: ''yabai -m rule --add app="^${app}$" manage=off''
  ) cfg.yabai.unmanagedApps;
in
{
  config = lib.mkIf (cfg.backend == "yabai") {
    pixdane.darwin.skhd.enable = lib.mkDefault true;

    services.yabai = {
      enable = true;
      enableScriptingAddition = cfg.yabai.scriptingAddition.enable;

      config = commonConfig // barPadding.${cfg.bar} // cfg.yabai.config;

      extraConfig = ''
        ${unmanagedAppRules}
        ${cfg.yabai.extraConfig}
      '';
    };
  };
}
