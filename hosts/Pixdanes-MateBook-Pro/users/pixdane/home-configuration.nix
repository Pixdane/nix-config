{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.home-shared
    ./fish.nix
  ];

  pixdane.features.enabled = [
    "fish"
    "git"
    "helix"
    "starship"
    "direnv"
    "zoxide"
    "zellij"
    "nixYourShell"
    "payRespects"
    "tools"
  ];

  programs.git = {
    settings.user = {
      name = "Pixdane";
      email = "yuanjin233@gmail.com";
    };
  };

  home.packages = with pkgs; [
    typst
    ffmpeg
    mpv
    dotnet-sdk_10
  ];
}
