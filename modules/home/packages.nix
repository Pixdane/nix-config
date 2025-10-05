{
  pkgs,
  inputs,
  osConfig,
  ...
}: {
  home.packages = with pkgs;
    [
      xz
      zstd
      ripgrep
      ncdu
      starship
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
    ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
      zip
      unzip
    ])
    ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
      skhd
    ]);
  # ++ (
  #   # you can access the host configuration using osConfig.
  #   # pkgs.lib.optionals (osConfig.programs.vim.enable && pkgs.stdenv.isDarwin) [ pkgs.skhd ]
  # );
}
