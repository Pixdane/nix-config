{pkgs, ...}: {
  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
