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
    fish
  ];

  boot.loader.systemd-boot.configurationLimit = 10;

  programs.vim.enable = true;

  # Allows running dynamically linked non-Nix binaries when needed.
  programs.nix-ld.enable = true;
}
