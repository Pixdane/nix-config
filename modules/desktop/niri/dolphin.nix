{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kdePackages.qtsvg
    kdePackages.kio-fuse #to mount remote filesystems via FUSE
    kdePackages.kio-extras #extra protocols support (sftp, fish and more);
    kdePackages.dolphin
  ];
}
