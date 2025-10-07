{pkgs, ...}: {
  imports = [
    ./settings.nix
    ./themes.nix
    # ./latex-support.nix
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
}
