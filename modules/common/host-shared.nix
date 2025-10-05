{
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs.self.modules.common; [
    gc
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
}
