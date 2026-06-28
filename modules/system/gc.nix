{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
    };

    optimise.automatic = true;
  };
}
