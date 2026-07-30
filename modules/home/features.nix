{
  config,
  lib,
  ...
}:
let
  featureNames = [
    "fish"
    "git"
    "helix"
    "starship"
    "direnv"
    "zoxide"
    "zellij"
    "nixYourShell"
    "payRespects"
    "tools"
    "wezterm"
    "rime"
  ];

  mkFeatureOption =
    name:
    lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Whether to enable the ${name} home feature.";
          };

          effectiveEnabled = lib.mkOption {
            type = lib.types.bool;
            readOnly = true;
            default =
              let
                cfg = config.pixdane.features.${name};
              in
              if cfg.enable != null then
                cfg.enable
              else
                builtins.elem name config.pixdane.features.enabled
                && !(builtins.elem name config.pixdane.features.disabled);
            description = "Resolved enable state for the ${name} home feature.";
          };
        };
      };
      default = { };
      description = "Configuration for the ${name} home feature.";
    };
in
{
  options.pixdane.features = {
    enabled = lib.mkOption {
      type = lib.types.listOf (lib.types.enum featureNames);
      default = [ ];
      description = "Home features to enable by default for this user.";
    };

    disabled = lib.mkOption {
      type = lib.types.listOf (lib.types.enum featureNames);
      default = [ ];
      description = "Home features to disable from the enabled feature set.";
    };
  }
  // lib.genAttrs featureNames mkFeatureOption;
}
