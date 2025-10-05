{pkgs, ...}: {
  programs.fish.enable = true;

  programs.fish.shellAliases = {
    "..." = "cd ../..";
  };

  programs.fish.plugins = [
    {
      name = "nix.fish";
      src = pkgs.fetchFromGitHub {
        owner = "kidonng";
        repo = "nix.fish";
        rev = "ad57d970841ae4a24521b5b1a68121cf385ba71e";
        sha256 = "sha256-GMV0GyORJ8Tt2S9wTCo2lkkLtetYv0rc19aA5KJbo48=";
      };
    }
  ];

  programs.starship.enableFishIntegration = true;

  programs.nix-your-shell.enableFishIntegration = true;

  programs.opam.enableFishIntegration = true;

  programs.pay-respects.enableFishIntegration = true;

  programs.zellij.enableFishIntegration = true;

  programs.fzf.enableFishIntegration = true;
}
