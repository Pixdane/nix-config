{
  pkgs,
  inputs,
  ...
}: {
  homebrew = {
    enable = true;

    casks = [
      "ubersicht"
    ];
  };
}
