{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./settings.nix
    ./themes.nix
    # ./latex-support.nix
  ];

  programs.helix = {
    enable = true;
    package = inputs.helix-flake.packages.${pkgs.system}.default;
    defaultEditor = true;
  };
}
