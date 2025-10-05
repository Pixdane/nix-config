{pkgs, ...}: {
  imports = [
    ./gc.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
}
