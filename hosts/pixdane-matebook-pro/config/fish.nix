{pkgs, ...}: {
  programs.fish.shellAliases = {
    code = "open -a \"Visual Studio Code\"";
  };

  programs.fish.shellInit = ''
    # Gaussian 16 installation
    set -x g16root /Applications/
    set -x GAUSS_SCRDIR /Applications/g16/scratch
    bass source /Applications/g16/bsd/g16.profile

    # For uv & ormolu & gen-hie
    fish_add_path $HOME/.local/bin
  '';
}
