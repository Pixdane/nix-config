{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  services.skhd = {
    enable = true;
    config = ''
      :: default : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh NOM black
      :: window : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh WIN black
      :: resize : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh RES black

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
  };
}
