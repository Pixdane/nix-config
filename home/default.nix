{
  pkgs,
  pkgs-stable,
  ...
}: {
  home.packages = with pkgs; [
    # Nix Formatter
    alejandra
    # Nix's Language Server
    nixd
    # Fix fish for using Nix
    nix-your-shell
    # Thefuck's replacement
    pay-respects
  ];

  programs.home-manager.enable = true;

  home.shell.enableShellIntegration = true;
}
