{
  pkgs,
  inputs,
  ...
}: {
  system.activationScripts.postActivation.text = ''
    su - pixdane -c '${pkgs.skhd}/bin/skhd -r'
  '';
}
