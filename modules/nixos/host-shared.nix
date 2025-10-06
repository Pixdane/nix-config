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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # To run non-nix executables:
  programs.nix-ld.enable = true;
}
