{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    # Already enabled by other config
    # enableFishIntegration = true;
  };
}
