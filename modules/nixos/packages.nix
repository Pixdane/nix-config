{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    helix
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    fish
  ];
}
