{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./desktop
    ./gaming.nix
    inputs.self.modules.system.base
    inputs.self.nixosModules.base
    inputs.self.nixosModules.desktop
    inputs.self.nixosModules.flatpak
    inputs.self.nixosModules.xremap
    inputs.self.nixosModules.fonts
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  pixdane.system = {
    nix.trustedUsers = [ "pixdane" ];
    fishShell.enable = true;
    helix.enable = true;
    xremap.enable = true;
    flatpak = {
      enable = true;
      packages = [
        {
          appId = "com.github.tchx84.Flatseal";
          origin = "flathub";
        } # Flatpak 权限管理 GUI
        {
          appId = "app.zen_browser.zen";
          origin = "flathub";
        } # Zen Browser
        {
          appId = "com.bitwarden.desktop";
          origin = "flathub";
        } # Bitwarden
        {
          appId = "org.mozilla.Thunderbird";
          origin = "flathub";
        } # Thunderbird 邮件客户端
      ];
    };
  };

  # Bootloader: Limine
  boot.loader = {
    systemd-boot.enable = false; # 关闭旧引导，避免与 Limine 冲突
    efi.canTouchEfiVariables = true;
    limine.enable = true;
  };

  networking.hostName = "sukumizu";

  # Configure network proxy if necessary
  networking.proxy.default = "http://192.168.31.235:7890/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking (NetworkManager 管理 Wi-Fi，不需要 wpa_supplicant)
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 桌面环境与 GPU 模式：可选 "kde-nvidia" / "niri-noctalia" / "none"
  pixdane.sukumizu.desktop = "niri-noctalia";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pixdane = {
    isNormalUser = true;
    description = "pixdane";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    warehouse # Flatpak 管理 GUI(浏览/安装/更新/管理 remotes)
  ];

  services.openssh.enable = true;

  # === 音频(PipeWire) ===
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # programs.steam.enable 已隐式设置,此处显式声明
    pulse.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
