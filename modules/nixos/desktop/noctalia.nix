{
  lib,
  config,
  ...
}:
{
  options.pixdane.desktop.noctalia = {
    enable = lib.mkEnableOption "Noctalia desktop shell";
  };

  config = lib.mkIf config.pixdane.desktop.noctalia.enable {
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true; # NetworkManager、蓝牙、电源管理
    };
  };
}
