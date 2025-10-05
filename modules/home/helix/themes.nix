{pkgs, ...}: {
  programs.helix.themes = {
    catppuccin_mocha_modified = builtins.fromTOML (builtins.readFile ./themes/catppuccin_mocha_modified.toml);
  };
}
