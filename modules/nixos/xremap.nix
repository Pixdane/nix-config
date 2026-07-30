{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.pixdane.system.xremap;
in
{
  imports = [ inputs.xremap-flake.nixosModules.default ];

  options.pixdane.system.xremap = {
    enable = lib.mkEnableOption "xremap key remapper with macOS-style keymap (native niri per-app support)";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "pixdane";
      description = "User running the graphical session.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xremap = {
      enable = true;
      withNiri = true;
      serviceMode = "user";
      userName = cfg.userName;

      # No modmap: physical keys stay as-is. xremap keymap intercepts
      # Alt+x (= macOS Cmd) and Super+arrows (= macOS Option) at the
      # evdev layer. Unmapped combos pass through untouched, so niri's
      # Mod+ (Super) window-management binds and bare modifier keys
      # are unaffected.
      #
      # Terminal apps: deliberately NOT mapped here. Alt+C/V/X/Z/W/T
      # pass through to wezterm, which binds them itself (see the
      # wezterm home feature module). This avoids SIGINT and lets the
      # terminal handle copy/paste with selection-awareness directly.
      #
      # Syntax verified against xremap upstream example/config.yml:
      #   Modifiers: M=Alt, C=Ctrl, Super=Super, Shift=Shift
      #   Key names: lowercase (left/right/up/down/home/end/backspace/delete)
      yamlConfig = ''
        keymap:
          # ----------------------------------------------------------
          # Global macOS Cmd shortcuts -> Linux Ctrl equivalents
          # Physical Alt acts as macOS Command.
          #
          # IMPORTANT: terminal apps are excluded so Alt+C/V/X/Z etc.
          # pass through untouched for wezterm to bind itself.
          # Without this, xremap converts Alt+C -> Ctrl+C before
          # wezterm ever sees it, and the wezterm ALT binding never
          # fires (Ctrl+C = SIGINT in terminal).
          # ----------------------------------------------------------
          - name: macOS Cmd
            application:
              not:
                - org.wezfurlong.wezterm
                - Alacritty
                - kitty
                - foot
            remap:
              # Basic editing
              M-c: C-c
              M-v: C-v
              M-x: C-x
              M-z: C-z
              M-Shift-z: C-Shift-z
              M-a: C-a
              M-s: C-s
              M-f: C-f
              M-g: C-g
              M-Shift-g: C-Shift-g
              M-p: C-p
              M-o: C-o

              # Window/tab (most apps honour Ctrl+W/T/N/Q)
              M-t: C-t
              M-n: C-n
              M-q: C-q

              # Text formatting
              M-b: C-b
              M-i: C-i
              M-u: C-u
              M-k: C-k

              # Cursor movement (Cmd layer - line/document bounds)
              M-left: home
              M-right: end
              M-up: C-home
              M-down: C-end

              # Selection (Shift+Cmd+arrows)
              M-Shift-left: Shift-home
              M-Shift-right: Shift-end
              M-Shift-up: C-Shift-home
              M-Shift-down: C-Shift-end

          # ----------------------------------------------------------
          # Option layer: word-wise movement/deletion (macOS Option)
          # Physical Super acts as macOS Option.
          # ----------------------------------------------------------
          - name: macOS Option
            remap:
              Super-left: C-left
              Super-right: C-right
              Super-up: C-up
              Super-down: C-down
              Super-Shift-left: C-Shift-left
              Super-Shift-right: C-Shift-right
              Super-Backspace: C-Backspace
              Super-Delete: C-Delete
      '';
    };
  };
}
