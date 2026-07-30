{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = config.pixdane.features.wezterm.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.wezterm = {
      enable = true;
      # macOS 原生 Cmd 已处理复制粘贴，无需额外 Alt 绑定。
      # Linux 上 Alt+C/V 由 xremap 排除终端（wezterm 在 not 列表中），
      # 因此 Alt 直达 wezterm，在此绑定 macOS 风格复制粘贴。
      # programs.wezterm.settings 合并生成 wezterm.lua，保留 shell 集成。
      extraConfig = lib.optionalString pkgs.stdenv.isLinux ''
        local wezterm = require 'wezterm'
        local act = wezterm.action

        config.keys = {
          -- Alt+C: 复制选区（无选区时为 no-op）
          {
            key = 'c',
            mods = 'ALT',
            action = wezterm.action_callback(function(window, pane)
              local has_selection = window:get_selection_text_for_pane(pane) ~= ""
              if has_selection then
                window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
                window:perform_action(act.ClearSelection, pane)
              end
            end),
          },

          -- Alt+V: 粘贴
          {
            key = 'v',
            mods = 'ALT',
            action = act.PasteFrom 'Clipboard',
          },
        }
      '';
    };
  };
}
