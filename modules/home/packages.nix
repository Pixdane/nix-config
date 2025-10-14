{
  pkgs,
  inputs,
  osConfig,
  ...
}: {
  home.packages = with pkgs;
    [
      helix
      xz
      zstd
      ntfs3g
      ripgrep
      ncdu
      # Nix Formatter
      alejandra
      # Nix's Language Server
      nixd
      # Another Nix's Language Server
      nix-your-shell
      # Thefuck's replacement
      pay-respects
      zathura
      typst
      ffmpeg
      mpv
      cachix
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
