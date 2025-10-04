{
  pkgs,
  pkgs-stable,
  ...
}: {
  home.packages = with pkgs; [
    # Nix Formatter
    alejandra
    # Nix Language Server
    nixd
    nix-your-shell
    # Thefuck replacement
    pay-respects
  ];

  programs.home-manager.enable = true;

  home.shell.enableShellIntegration = true;
}
