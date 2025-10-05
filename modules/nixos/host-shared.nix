{
  pkgs,
  inputs,
  ...
}: {
  imports = with inputs.self.nixosModules; [
    packages
  ];

  # do not need to keep too much generations
  boot.loader.systemd-boot.configurationLimit = 10;
  # boot.loader.grub.configurationLimit = 10;

  programs.vim.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # you can check if host is darwin by using pkgs.stdenv.isDarwin
  # environment.systemPackages = [
  #   pkgs.btop
  # ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.xbar ]);
}
