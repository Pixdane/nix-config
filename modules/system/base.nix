{ inputs, ... }: {
  imports = with inputs.self.modules.system; [
    nix
    gc
    fish-shell
    helix
  ];
}
