{pkgs, ...}: {
  home.packages = with pkgs; [
    starship
  ];

  programs.starship.enable = true;

  programs.starship.settings =
    builtins.fromTOML (builtins.readFile "${pkgs.starship.src}/docs/public/presets/toml/pure-preset.toml");
}
