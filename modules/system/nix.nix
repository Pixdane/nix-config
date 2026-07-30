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

    # helix flake 的二进制缓存
    substituters = [ "https://helix.cachix.org" ];
    trusted-public-keys = [ "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=" ];
  };
}
