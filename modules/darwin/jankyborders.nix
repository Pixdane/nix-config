{
  pkgs,
  inputs,
  ...
}: {
  services.jankyborders = {
    enable = true;
    active_color = "0xffe1e3e4";
    inactive_color = "0xff494d64";
  };
}
