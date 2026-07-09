{
  config,
  lib,
  ...
}:
{
  options.pixdane.system.nix.trustedUsers = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Extra users allowed to perform trusted Nix daemon operations.";
  };

  config.nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = lib.mkForce (lib.unique ([ "root" ] ++ config.pixdane.system.nix.trustedUsers));
  };
}
