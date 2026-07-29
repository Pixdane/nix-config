{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.self.modules.system.base
    inputs.self.nixosModules.base
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  pixdane.system = {
    nix.trustedUsers = [ "pixdane" ];
    fishShell.enable = true;
    helix.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Configure keymap in X11
  services.xserver = {
    enable = true; # PRIME sync 仅限 X11，需要显式启用
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = [ "nvidia" ];
  };

  # === KDE Plasma 6 ===
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false; # PRIME sync 仅限 X11，使用 X11 登录界面更稳定
  };
  services.desktopManager.plasma6.enable = true;

  # === NVIDIA Pascal GTX 1050 Mobile (Intel + NVIDIA Optimus) ===
  # Pascal 架构只能用 PRIME sync 模式（offload 需要 Turing+），NVIDIA 始终通电
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32 位应用（Wine、Steam）
  };

  hardware.nvidia = {
    modesetting.enable = true; # KMS，添加 nvidia-drm.modeset=1
    open = false; # Pascal 不支持开源内核模块（需 Turing+）

    # Pascal 已被 stable 595+ 弃用，必须使用 legacy_580 分支
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # PRIME sync：NVIDIA 渲染一切，Intel iGPU 仅作显示输出（仅 X11）
    prime = {
      sync.enable = true;

      # lspci 0000:00:02.0 (Intel) -> PCI:0:2:0
      intelBusId = "PCI:0:2:0";
      # lspci 0000:01:00.0 (NVIDIA) -> PCI:1:0:0
      nvidiaBusId = "PCI:1:0:0";
    };

    # Pascal 不支持 finegrained（需 Turing+ 和 offload）和 Dynamic Boost（需 Ampere+）
    powerManagement.enable = true; # 挂起时保留 VRAM（实验性）
    nvidiaSettings = true;
  };

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
  environment.systemPackages = with pkgs; [ ];

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
