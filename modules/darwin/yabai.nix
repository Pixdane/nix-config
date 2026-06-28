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

  skhdModeHeader = {
    none = ''
      :: default
      :: window
      :: resize
    '';
    simple-bar = ''
      :: default : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh NOM black
      :: window : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh WIN black
      :: resize : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh RES black
    '';
  };

  yabaiSkhdConfig = ''
    ${skhdModeHeader.${cfg.bar}}
    cmd - 0x32 ; window
    window < cmd - 0x32 ; default
    window < escape ; default
    window < r ; resize
    resize < r ; window
    resize < escape ; default

    # focus space
    ctrl - 0x21 : yabai -m space --focus prev || yabai -m space --focus last
    ctrl - 0x1E : yabai -m space --focus next || yabai -m space --focus first
    ralt - 0x21 : yabai -m space --focus prev || yabai -m space --focus last
    ralt - 0x1E : yabai -m space --focus next || yabai -m space --focus first
    window < 0x21 : yabai -m space --focus prev || yabai -m space --focus last
    window < 0x1E : yabai -m space --focus next || yabai -m space --focus first

    # focus window
    window < h : yabai -m window --focus west
    window < j : yabai -m window --focus south
    window < k : yabai -m window --focus north
    window < l : yabai -m window --focus east
    window < n : yabai -m window --focus stack.next
    window < p : yabai -m window --focus stack.prev

    # swap window
    window < shift - h : yabai -m window --swap west
    window < shift - j : yabai -m window --swap south
    window < shift - k : yabai -m window --swap north
    window < shift - l : yabai -m window --swap east
    window < shift - n : yabai -m window --swap stack.next  # Navigate stack next
    window < shift - p : yabai -m window --swap stack.prev  # Navigate stack prev

    # float / unfloat window and center on screen
    window < t : yabai -m window --toggle float --grid 4:4:1:1:2:2

    # balance size of windows
    window < o : yabai -m space --balance

    # send window to desktop and follow focus
    window < shift - 0x21 : yabai -m window --space prev --focus || yabai -m window --space last --focus
    window < shift - 0x1E : yabai -m window --space next --focus || yabai -m window --space first --focus

    # warp operations - alt + shift + hjkl for warping
    window < alt + shift - h : yabai -m window --warp west
    window < alt + shift - j : yabai -m window --warp south
    window < alt + shift - k : yabai -m window --warp north
    window < alt + shift - l : yabai -m window --warp east

    # stack operations - ctrl + shift + hjkl for stacking
    window < s : yabai -m window --insert stack  # Toggle stack mode
    window < u : yabai -m window --toggle float; yabai -m window --toggle float  # Unstack window
    window < ctrl + shift - h : yabai -m window --stack west
    window < ctrl + shift - j : yabai -m window --stack south
    window < ctrl + shift - k : yabai -m window --stack north
    window < ctrl + shift - l : yabai -m window --stack east

    # resize window
    resize < h : yabai -m window --resize left:-20:0
    resize < j : yabai -m window --resize bottom:0:20
    resize < k : yabai -m window --resize top:0:-20
    resize < l : yabai -m window --resize right:20:0
  '';
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

    services.skhd.skhdConfig = yabaiSkhdConfig;
  };
}
