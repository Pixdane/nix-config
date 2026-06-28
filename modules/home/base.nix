{ inputs, ... }: {
  imports = with inputs.self.homeModules; [
    features
    fish
    git
    helix
    starship
    direnv
    zoxide
    zellij
    nix-your-shell
    pay-respects
    tools
    darwin-desktop
  ];

  home.stateVersion = "25.05";
}
