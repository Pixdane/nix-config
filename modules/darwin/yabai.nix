{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    config = {
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
      bottom_padding = 50;
      left_padding = 4;
      right_padding = 4;
      window_gap = 4;
    };

    extraConfig = ''
      yabai -m rule --add app="^系统设置$" manage=off
      yabai -m rule --add app="^QQ$" manage=off
      yabai -m rule --add app="^微信$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add app="^归档实用工具$" manage=off
      yabai -m rule --add app="^Microsoft To Do$" manage=off
    '';
  };
}
