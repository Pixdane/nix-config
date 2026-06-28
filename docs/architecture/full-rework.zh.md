# Nix 配置重构架构

本文记录 `codex/full-rework` 分支当前的模块结构、配置边界和剩余约束。已经由代码清楚表达的细节不在这里重复；后续待讨论事项放在仓库根目录 `TODO.md`。

## 当前目标

这个仓库使用 Blueprint 生成 flake outputs，同时支持：

- nix-darwin 机器。
- NixOS 机器。
- 多个 host 下的 home-manager 用户配置。
- standalone home-manager 设备，前提是这些设备只消费 home-manager 能管理的用户态配置。

当前重心是 macOS / nix-darwin；NixOS 保持结构可用，但短期不是主力使用目标。

## Blueprint 布局

继续使用 Blueprint 默认布局，不启用 `prefix = "nix/"`，也不新增顶层 `profiles/`。

关键入口：

```nix
inputs.self.modules.system.base
inputs.self.darwinModules.base
inputs.self.nixosModules.base
inputs.self.homeModules.base
```

当前顶层分层：

```text
modules/system/   # Darwin 和 NixOS 共享的系统抽象
modules/darwin/   # nix-darwin 专属系统能力
modules/nixos/    # NixOS 专属系统能力
modules/home/     # home-manager 用户环境
```

当前主要 module outputs：

```text
modules.system: nix, gc, fish-shell, helix, base
darwinModules: base, homebrew, touch-id-sudo, ubersicht, window-manager
nixosModules: base
homeModules: base, cli, features, helix, ubersicht, window-manager
```

## 抽象原则

优先使用 NixOS、nix-darwin、home-manager 的原生 option。只有在原生 option 不能准确表达需求，或者一个功能需要组合多个底层 option 时，才增加 `pixdane.*` 自定义 option。

适合直接使用原生 option 的 host 事实：

```nix
system.primaryUser
users.users
nixpkgs.hostPlatform
networking.hostName
system.stateVersion
```

当前自定义 API：

```nix
pixdane.system.nix.trustedUsers
pixdane.system.fishShell.enable
pixdane.system.helix.enable
pixdane.features.*
pixdane.darwin.windowManager.*
pixdane.darwin.skhd.enable
pixdane.darwin.ubersicht.enable
```

`pixdane.*` 不替代所有底层配置，只表达可复用 feature、跨平台抽象或组合意图。

## Evaluation 边界

NixOS、nix-darwin 和 home-manager 是不同的 module evaluation。相同名字的 option 不会自动跨 evaluation 同步。

例如：

- system 层 fish 支持由 `pixdane.system.fishShell.enable` 控制。
- home-manager 层 fish 用户体验由 `pixdane.features.fish.enable` 控制。

二者可以在 host 中同时打开，但不是靠名字自动联动。

普通 home modules 默认不隐式依赖 `osConfig`，以保持 standalone home-manager 可用。例外是 Darwin 桌面集成，例如 simple-bar；它依赖 nix-darwin 侧的 window-manager 选择，因此读取 `osConfig.pixdane.darwin.windowManager.*`。

## Feature 模型

home feature 默认不因为 import 而启用。host 使用 `enabled` / `disabled` 批量选择，也可以用单项 `enable` 精确覆盖。

当前 Mac host 的 feature 列表：

```nix
pixdane.features.enabled = [
  "fish"
  "git"
  "helix"
  "starship"
  "direnv"
  "zoxide"
  "zellij"
  "nixYourShell"
  "payRespects"
  "tools"
];
```

语义：

- import 表示功能可用，不表示启用。
- `enabled` 批量打开。
- `disabled` 批量关闭。
- `pixdane.features.<name>.enable` 保留为单项入口。

## System 层

`modules/system/base.nix` 导入：

```text
nix.nix
gc.nix
fish-shell.nix
helix.nix
```

当前行为：

- `nix.nix` 总是打开 `nix-command` 和 `flakes`。
- `pixdane.system.nix.trustedUsers` 只配置普通 trusted users，模块内部总是加上 `root`。
- standalone home-manager 不会应用 Nix daemon 设置。
- `gc.nix` 打开自动 GC 和 store optimise，GC options 为 `--delete-older-than 1w`。
- `fish-shell.nix` 打开系统 fish 支持；Darwin 额外写 `environment.shells = [ pkgs.fish ]`。
- `helix.nix` 把 upstream HEAD Helix 作为系统编辑器，设置 `EDITOR` / `VISUAL` 为 `hx`。

用户 login shell 仍直接写在 host 的 `users.users.<name>.shell`，不由 home-manager 管理。

## Darwin 层

当前结构：

```text
modules/darwin/base.nix
modules/darwin/homebrew.nix
modules/darwin/touch-id-sudo.nix
modules/darwin/ubersicht.nix
modules/darwin/window-manager/default.nix
modules/darwin/window-manager/skhd.nix
modules/darwin/window-manager/yabai.nix
modules/darwin/window-manager/simple-bar.nix
```

`darwinModules.base` 导入 Touch ID sudo、Homebrew、Übersicht 和 window-manager。

固定决策：

- Touch ID sudo 默认打开。
- Homebrew 默认打开，并启用 bash/zsh/fish shell integration。
- Homebrew base 不放具体 taps、brews、casks。
- `system.primaryUser`、`users.users`、`nixpkgs.hostPlatform` 等仍由 host 直接写。

### Window Manager

`modules/darwin/window-manager/default.nix` 定义：

```nix
pixdane.darwin.windowManager = {
  backend = "none"; # "none" | "yabai"
  bar = "none";     # "none" | "simple-bar"
};
```

`backend = "yabai"` 时：

- 启用 `services.yabai`。
- 默认启用 skhd。
- yabai config 使用“仓库默认 + bar padding + host override”合并。
- `scriptingAddition.enable` 默认关闭；当前 Mac host 显式打开。
- `unmanagedApps` 由 host 写当前机器需要排除的 app。

`bar = "simple-bar"` 时：

- yabai bottom padding 使用 simple-bar 对应值。
- skhd mode header 调用 simple-bar 的 mode script。
- Darwin 侧默认打开 `pixdane.darwin.ubersicht.enable`。

`skhd` 可以脱离 yabai 单独启用。`sketchybar` 暂不进入 `bar` enum。

## Home 层

当前结构：

```text
modules/home/base.nix
modules/home/features.nix
modules/home/cli/default.nix
modules/home/helix/default.nix
modules/home/ubersicht.nix
modules/home/window-manager/default.nix
```

`homeModules.base` 导入上述模块，并设置 `home.stateVersion = "25.05"`。旧 `home-shared` 入口已删除，host 直接 import `inputs.self.homeModules.base`。

### CLI

`modules/home/cli/default.nix` 聚合：

```text
fish.nix
git.nix
starship.nix
direnv.nix
zoxide.nix
zellij.nix
nix-your-shell.nix
pay-respects.nix
tools.nix
```

原则：

- shell integration 放在对应软件模块，不集中塞进 fish。
- `git` 用户名和邮箱写在 host/user 本地配置。
- `tools` 只放通用 CLI 工具和仓库维护工具。
- `nix-search-cli` 跟随 `payRespects`，因为当前 command-not-found 体验来自 `pay-respects cnf -> nix-search`。
- `fzf` 第一版删除；`fd` 保留在 tools。
- `typst`、`ffmpeg`、`mpv`、`dotnet-sdk_10` 是当前 Mac host local 包，不进入公共 feature。

### Helix

Helix 单独放在 `modules/home/helix/`，不放进 CLI。当前 home Helix 使用 upstream HEAD input，保留 settings/theme，并配置 Nix formatter 为 `pkgs.nixfmt`。

`latex-support.nix` 保留为未迁移的本地 LaTeX 配置候选，默认不 import。后续见 `TODO.md`。

### Übersicht 和 simple-bar

`modules/home/ubersicht.nix` 管理：

```text
~/.config/ubersicht -> ~/Library/Application Support/Übersicht
```

simple-bar 作为 bar/widget 配置保留在：

```text
modules/home/window-manager/simple-bar/
```

当 nix-darwin 侧选择 `pixdane.darwin.windowManager.bar = "simple-bar"` 时，home-manager 部署 simple-bar widget repo 和 `.simplebarrc`。

simple-bar 固定为 flake input，并应用 `modules/home/window-manager/simple-bar/patches/local-current.patch`。该 patch 的目标是复现当前本机 simple-bar checkout；已用 store output 和 `.backups/simple-bar-current-7673cbbc` 对比验证过。

## NixOS 层

当前只有：

```text
modules/nixos/base.nix
```

它收敛旧 NixOS shared 模块中的基础行为：

- `boot.loader.systemd-boot.configurationLimit = 10`
- `programs.vim.enable = true`
- `programs.nix-ld.enable = true`
- 系统包：`git`、Helix HEAD、`vim`、`wget`

`fish` 不在 NixOS base 里重复安装；它来自共享 system 层 `pixdane.system.fishShell.enable`。

Parallels VM、NetworkManager、proxy、locale、用户、autologin 等仍是 `hosts/nixos-parallels/configuration.nix` 的 host local 事实。后续是否拆 `modules/nixos/vm.nix` 见 `TODO.md`。

## Deprecated / 保留库存

`modules/home/window-manager/sketchybar/` 保留为弃用的 legacy snapshot：

- 不接入 `home/base.nix`。
- 不进入第一版 feature/bar 选择。
- 手动 import 时会发出 warning。
- 当前正式 bar 路径是 simple-bar。

已删除或暂不恢复：

- `jankyborders` 不进入第一版。
- `ntfs3g` 第一版不恢复；如果以后需要 NTFS 写入，应单独设计 Darwin/macFUSE 能力。

## Backlog

继续讨论前先看 `TODO.md`。当前 backlog 包括：

- VS Code
- Helix LaTeX
- Zellij
- WezTerm
- NixOS 拆分
