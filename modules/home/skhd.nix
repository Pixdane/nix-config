{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: {
  services.skhd = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = ''
      # focus window
      # ctrl - a : yabai -m window --focus west
      # ctrl - s : yabai -m window --focus south
      # ctrl - w : yabai -m window --focus north
      # ctrl - d : yabai -m window --focus east
      # ralt - a : yabai -m window --focus west
      # ralt - s : yabai -m window --focus south
      # ralt - w : yabai -m window --focus north
      # ralt - d : yabai -m window --focus east

      # swap managed window
      ctrl - 0x2A : yabai -m window --swap next || yabai -m window --swap first
      ctrl + shift - 0x2A : yabai -m window --swap prev || yabai -m window --swap last
      ralt - 0x2A : yabai -m window --swap next || yabai -m window --swap first
      ralt + shift - 0x2A : yabai -m window --swap prev || yabai -m window --swap last

      # balance size of windows
      shift + ralt - 0 : yabai -m space --balance

      # send window to desktop and follow focus
      ctrl + shift - 0x21 : yabai -m window --space prev; yabai -m space --focus prev
      ctrl + shift - 0x1E : yabai -m window --space next; yabai -m space --focus next
      ctrl - 0x21 : yabai -m space --focus prev || yabai -m space --focus last
      ctrl - 0x1E : yabai -m space --focus next || yabai -m space --focus first
      ralt + shift - 0x21 : yabai -m window --space prev; yabai -m space --focus prev
      ralt + shift - 0x1E : yabai -m window --space next; yabai -m space --focus next
      ralt - 0x21 : yabai -m space --focus prev || yabai -m space --focus last
      ralt - 0x1E : yabai -m space --focus next || yabai -m space --focus first

      # increase window size
      ctrl + shift - a : yabai -m window --resize left:-20:0 || yabai -m window --resize right:-20:0
      ctrl + shift - w : yabai -m window --resize top:0:-20 || yabai -m window --resize bottom:0:-20
      ctrl + shift - d : yabai -m window --resize left:20:0 || yabai -m window --resize right:20:0
      ctrl + shift - s : yabai -m window --resize top:0:20 || yabai -m window --resize bottom:0:20
      ralt + shift - a : yabai -m window --resize left:-20:0 || yabai -m window --resize right:-20:0
      ralt + shift - w : yabai -m window --resize top:0:-20 || yabai -m window --resize bottom:0:-20
      ralt + shift - d : yabai -m window --resize left:20:0 || yabai -m window --resize right:20:0
      ralt + shift - s : yabai -m window --resize top:0:20 || yabai -m window --resize bottom:0:20

      # float / unfloat window and center on screen
      alt - t : yabai -m window --toggle float --grid 4:4:1:1:2:2
    '';
  };
}
