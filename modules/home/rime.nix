{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = config.pixdane.features.rime.effectiveEnabled;
  isDarwin = pkgs.stdenv.isDarwin;

  # rime-ice 打包时把 default.yaml 重命名为 rime_ice_suggestion.yaml 以避免
  # 与官方 rime-data 的 default.yaml 冲突。这里恢复为 default.yaml 作为入口。
  # （数据包定义与 modules/system/rime.nix 保持一致，NixOS 走 fcitx5-rime.override
  #   注入；Darwin 由本模块放到 Squirrel 用户目录。）
  rimeDefault = pkgs.runCommand "rime-ice-default" { } ''
    mkdir -p $out/share/rime-data
    cp ${pkgs.rime-ice}/share/rime-data/rime_ice_suggestion.yaml \
       $out/share/rime-data/default.yaml
  '';

  # 微软双拼补丁（以 patch 方式打补丁，不修改 rime-ice 原文件，便于全量更新）
  rimePatches = [
    (pkgs.writeTextDir "share/rime-data/default.custom.yaml" ''
      patch:
        schema_list:
          - schema: double_pinyin_mspy
        ascii_composer/switch_key/Caps_Lock: commit_code
        ascii_composer/switch_key/Shift_L: noop
    '')
    (pkgs.writeTextDir "share/rime-data/melt_eng.custom.yaml" ''
      patch:
        speller/algebra:
          __include: melt_eng.schema.yaml:/algebra_double_pinyin_mspy
    '')
    (pkgs.writeTextDir "share/rime-data/radical_pinyin.custom.yaml" ''
      patch:
        speller/algebra:
          __include: radical_pinyin.schema.yaml:/algebra_double_pinyin_mspy
    '')
  ];

  rimeDataPkgs = [
    pkgs.rime-ice
    rimeDefault
  ] ++ rimePatches;
in
{
  # 仅 macOS 生效：把 rime-ice 数据放到 Squirrel 用户目录 ~/Library/Rime/
  # Squirrel 是 macOS 官方 Rime 前端，配置目录固定为此。
  # NixOS 上数据由系统层 modules/nixos/desktop/rime.nix 通过 fcitx5-rime.override 注入，
  # 不需要 home 放文件，故 Linux 下本模块为空操作。
  config = lib.mkIf (enabled && isDarwin) {
    home.file."Library/Rime".source =
      (pkgs.symlinkJoin {
        name = "rime-ice-data";
        paths = rimeDataPkgs;
      }) + "/share/rime-data";
  };
}
