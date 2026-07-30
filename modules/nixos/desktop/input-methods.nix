{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.pixdane.desktop.inputMethods;

  # rime-ice 打包时把 default.yaml 重命名为 rime_ice_suggestion.yaml 以避免
  # 与官方 rime-data 的 default.yaml 冲突。这里恢复为 default.yaml 作为入口。
  # （数据包定义与 modules/home/rime.nix 保持一致，Darwin 走 home.file 放到
  #   Squirrel 用户目录；NixOS 由本模块通过 fcitx5-rime.override 注入。）
  rimeDefault = pkgs.runCommand "rime-ice-default" { } ''
    mkdir -p $out/share/rime-data
    cp ${pkgs.rime-ice}/share/rime-data/rime_ice_suggestion.yaml \
       $out/share/rime-data/default.yaml
  '';

  # 微软双拼补丁（以 patch 方式打补丁，不修改 rime-ice 原文件，便于全量更新）
  # - default.custom.yaml:      方案列表只保留微软双拼
  # - melt_eng.custom.yaml:      英文次翻译器切换为微软双拼拼写派生
  # - radical_pinyin.custom.yaml: 拆字反查/辅码切换为微软双拼拼写派生
  rimePatches = [
    (pkgs.writeTextDir "share/rime-data/default.custom.yaml" ''
      patch:
        schema_list:
          - schema: double_pinyin_mspy
        # CapsLock 由 fcitx5 框架级 TriggerKeys 拦截，Rime 收不到该键，
        # 故不在此设置 Caps_Lock。Shift_L 仍由 Rime 处理。
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
  ]
  ++ rimePatches;
in
{
  options.pixdane.desktop.inputMethods = {
    enable = lib.mkEnableOption "fcitx5 聚合输入法（中文 Rime + 日语 Mozc + 希腊语 + Emoji）";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          # 中文：雾凇拼音（微软双拼）
          (fcitx5-rime.override { inherit rimeDataPkgs; })
          # 日语：Mozc（Google 日文输入法开源版）
          fcitx5-mozc
          # 配置工具
          qt6Packages.fcitx5-configtool
        ];

        # 框架级热键（写入 /etc/xdg/fcitx5/config）
        # - CapsLock: 激活/非激活输入法
        # - Control+space: 轮换输入法
        # CapsLock 在框架层被拦截，Rime 的 ascii_composer 收不到该键。
        settings.globalOptions.Hotkey = {
          TriggerKeys = "Caps_Lock";
          EnumerateForwardKeys = "Control+space";
        };

        # 声明式输入法列表（写入 /etc/xdg/fcitx5/profile）
        # 注意：这会覆盖用户在 GUI 里的手动配置，rebuild 后还原为此处定义。
        # 希腊语和 Emoji 无需额外 addon：
        # - keyboard-gr 是 fcitx5 核心自带的 Keyboard Engine 挂载 XKB 布局
        # - Emoji 模块内置于 fcitx5 核心，在 keyboard engine 下输入 :keyword: 触发
        settings.inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "rime";
          "Groups/0/Items/2".Name = "mozc";
          "Groups/0/Items/3".Name = "keyboard-gr";
          GroupOrder."0" = "Default";
        };
      };
    };

    # Emoji：fcitx5 核心内置 emoji 模块（keyboard engine 下输入 :keyword: 触发）
    # emote 作为独立的 GTK emoji picker 补充，按需启动，点击即粘贴到当前焦点窗口
    environment.systemPackages = [ pkgs.emote ];
  };
}
