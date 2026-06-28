{ lib, ... }:
{
  options.pixdane.darwin.windowManager = {
    backend = lib.mkOption {
      type = lib.types.enum [
        "none"
        "yabai"
      ];
      default = "none";
      description = "Darwin window manager backend.";
    };

    bar = lib.mkOption {
      type = lib.types.enum [
        "none"
        "simple-bar"
      ];
      default = "none";
      description = "Darwin desktop bar integration.";
    };

    yabai = {
      scriptingAddition.enable = lib.mkEnableOption "yabai scripting addition";

      config = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Host-specific yabai config overrides.";
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra yabai commands appended after generated config.";
      };

      unmanagedApps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Application names that yabai should not manage.";
      };
    };
  };
}
