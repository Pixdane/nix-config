{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    inputs.helix-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
    vim
    wget
  ];

  boot.loader.systemd-boot.configurationLimit = 10;

  # Allows running dynamically linked non-Nix binaries when needed.
  programs.nix-ld.enable = true;
}
