{
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs.self.darwinModules; [
    activate-fish
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    yabai
  ];
}
