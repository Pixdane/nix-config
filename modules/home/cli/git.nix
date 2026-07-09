{
  config,
  lib,
  ...
}:
let
  enabled = config.pixdane.features.git.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.git = {
      enable = true;
      settings = {
        core.autocrlf = false;
        core.eol = "lf";
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
