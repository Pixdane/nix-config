{
  lib,
  ...
}:
{
  imports = [
    ./kde-nvidia.nix
    ./niri-noctalia.nix
  ];

  options.pixdane.sukumizu.desktop = lib.mkOption {
    type = lib.types.enum [
      "none"
      "kde-nvidia"
      "niri-noctalia"
    ];
    default = "none";
    description = "Desktop environment and GPU mode for the sukumizu host.";
  };
}
