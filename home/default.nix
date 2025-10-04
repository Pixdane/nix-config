{
  pkgs,
  pkgs-stable,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
  ];

  programs.home-manager.enable = true;
}
