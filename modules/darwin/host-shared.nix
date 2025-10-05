{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.self.modules.common.host-shared];
}
