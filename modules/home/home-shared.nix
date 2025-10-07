{
  pkgs,
  inputs,
  osConfig,
  ...
}: {
  imports = with inputs.self.homeModules; [
    packages
    fish
    git
    starship
    direnv
    helix

    # Darwin only
    skhd
    sketchybar
  ];

  # only available on linux, disabled on macos
  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.shell.enableShellIntegration = true;

  home.stateVersion = "25.05"; # initial home-manager state
}
