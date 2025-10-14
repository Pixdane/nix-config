{
  pkgs,
  inputs,
  ...
}: {
  # Workaround: Single-user only
  system.activationScripts.postActivation.text = ''
    su - pixdane -c '${pkgs.skhd}/bin/skhd -r'
  '';
}
