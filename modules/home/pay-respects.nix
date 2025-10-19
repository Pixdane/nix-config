{pkgs, ...}: {
  programs.pay-respects = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
