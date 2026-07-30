{
  lib,
  inputs,
  ...
}:
{
  # Noctalia 已在 nixpkgs-unstable 上游化（nixos/modules/programs/wayland/noctalia.nix），
  # 与 flake 的 inputs.noctalia.nixosModules.default 重复声明 programs.noctalia.enable。
  # 这里禁用上游模块，保留 flake 模块以命中 noctalia cachix 二进制缓存。
  disabledModules = [ "programs/wayland/noctalia.nix" ];

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
