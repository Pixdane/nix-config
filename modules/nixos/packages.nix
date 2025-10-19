{
  pkgs,
  inputs,
  helix-flake,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    inputs.helix-flake.packages.${pkgs.system}.default
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    fish
  ];
}
