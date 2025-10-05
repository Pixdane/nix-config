{pkgs, ...}: {
  programs.starship = {
    enable = true;

    settings =
      builtins.fromTOML (builtins.readFile "${pkgs.starship.src}/docs/public/presets/toml/pure-preset.toml");
  };
}
