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
      # Nix Formatter
      alejandra
      # Nix's Language Server
      nixd
      # Another Nix's Language Server
      nix-your-shell
      zathura
      typst
      ffmpeg
      mpv
      cachix

      # For terminal
      jq
      fd
      ripgrep
      ncdu
      # Thefuck's replacement
      pay-respects
      nushell
      yazi
      zoxide
      fzf
      lazygit
      ouch
      atuin
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
