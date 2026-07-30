{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia.nixosModules.default
    ./greetd.nix
    ./input-methods.nix
    ./kde.nix
    ./niri.nix
    ./noctalia.nix
  ];

  # Noctalia cachix(始终配置，确保首次构建也能命中缓存)
  nix.settings = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
}
