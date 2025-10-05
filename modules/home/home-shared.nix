{
  pkgs,
  inputs,
  osConfig,
  ...
}: {
  imports = with inputs.self.homeModules; [
    fish
    git
    starship
  ];

  # only available on linux, disabled on macos
  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.packages = with pkgs;
    [
      xz
      ripgrep
      # Nix Formatter
      alejandra
      # Nix's Language Server
      nixd
      # Another Nix's Language Server
      nil
      # Fix fish for using Nix
      nix-your-shell
      # Thefuck's replacement
      pay-respects
    ]
    ++ (
      # you can access the host configuration using osConfig.
      pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
        zip
        unzip
      ])
    );
  # ++ (
  #   # you can access the host configuration using osConfig.
  #   # pkgs.lib.optionals (osConfig.programs.vim.enable && pkgs.stdenv.isDarwin) [ pkgs.skhd ]
  # );

  home.shell.enableShellIntegration = true;

  home.stateVersion = "25.05"; # initial home-manager state
}
