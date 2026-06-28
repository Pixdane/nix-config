# Nix 配置重构设计记录

本文记录 `codex/full-rework` 分支上的 full rework 讨论结论。它是当前重构的架构说明和后续实现依据，不是已经完成的实现说明。

当前状态：

- 已创建重构分支：`codex/full-rework`。
- 目前只整理设计文档，尚未重写模块实现。
- 当前重心是 macOS / nix-darwin。
- NixOS 和 standalone home-manager 也要进入新结构，但短期不是主力使用目标。

## 目标

这个仓库继续作为个人 Nix 配置仓库，使用 Blueprint 生成 flake outputs，同时支持：

- 多台 nix-darwin 机器。
- 多台 NixOS 机器。
- 多个 host 下的 home-manager 用户配置。
- standalone home-manager 设备，前提是这些设备只消费 home-manager 能管理的用户态配置。

重构目标不是把所有配置抽象成一套巨大 DSL，而是让共享配置、平台配置、host 本地事实之间的边界更清楚。

## Blueprint 约束

继续使用 Blueprint 的默认顶层布局，不启用 `prefix = "nix/"`。

保留 Blueprint 约定目录：

```text
flake.nix
hosts/
modules/
templates/
```

不新增顶层 `profiles/`。如果需要“组合配置”的概念，优先通过 Blueprint 可发现的 module 文件表达，例如：

```text
modules/system/base.nix
modules/home/base.nix
modules/home/tools.nix
modules/darwin/base.nix
modules/darwin/desktop.nix
modules/nixos/base.nix
modules/nixos/vm.nix
```

这样输出仍然自然：

```nix
inputs.self.modules.system.base
inputs.self.homeModules.base
inputs.self.darwinModules.base
inputs.self.nixosModules.base
```

## 抽象原则

优先使用 NixOS、nix-darwin、home-manager 的原生 option。只有在原生 option 不能准确表达需求，或者一个功能需要组合多个底层 option 时，才增加 `pixdane.*` 自定义 option。

适合直接使用原生 option 的机器事实：

```nix
system.primaryUser
users.users
nixpkgs.hostPlatform
networking.hostName
system.stateVersion
```

适合自定义 option 的共享功能：

```nix
pixdane.system.nix.trustedUsers
pixdane.system.fishShell.enable
pixdane.system.helix.enable
pixdane.features.*
pixdane.darwin.windowManager.*
```

`pixdane.*` 是本仓库的配置 API。它不替代所有底层配置，只表达可复用 feature、跨平台抽象或组合意图。

如果原生 option 正好能表达我们想要的语义，而且已经比较简洁，就不再包一层自己的配置。

## Module Evaluation 边界

NixOS、nix-darwin 和 home-manager 是不同的 module evaluation。相同名字的 option 不会自动跨 evaluation 同步。

例如：

- system 层的 fish 支持由 `pixdane.system.fishShell.enable` 控制。
- home-manager 层的 fish 用户体验由 `pixdane.features.fish.enable` 控制。

二者可以在 host 或 bundle 中同时打开，但不是靠名字自动联动。

默认不让普通 home modules 隐式依赖 `osConfig`。这样 home-manager 配置可以 standalone 使用。

例外是 Darwin-only 的 home 桌面集成，例如 simple-bar。它本来就依赖 nix-darwin 侧的窗口管理器选择，因此可以读 `osConfig.pixdane.darwin.windowManager.*`。

## 目录分层

计划使用以下分层：

```text
modules/system/   # Darwin 和 NixOS 可共享的系统抽象
modules/darwin/   # nix-darwin 专属系统能力
modules/nixos/    # NixOS 专属系统能力
modules/home/     # home-manager 用户环境
```

`modules/system` 只放两个平台都能共享且低争议的系统基础。Darwin-only 和 NixOS-only 能力仍保留在各自平台目录，避免一个大模块里堆满平台分支。

host 使用时可以 import 对应入口模块，然后写 host 事实和 feature 选择。

## Feature 选择模型

home feature 不再默认“全部打开”。import 模块只表示“这个功能可用”，不表示启动。

host 可以用列表批量选择 feature：

```nix
pixdane.features = {
  enabled = [
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

  disabled = [
    # 可选，用来从某组选择中减掉 feature
  ];
};
```

每个模块仍然有自己的最终开关，例如：

```nix
pixdane.features.zellij.enable = true;
```

目标语义：

- 默认情况下，feature 不会因为 import 了模块就启动。
- `enabled` 负责批量打开。
- `disabled` 负责批量关闭。
- per-feature 的 `pixdane.features.<name>.enable` 保留为精确入口。
- 将来如果引入 profile，profile 也只是提供一组 `enabled` / `disabled`，host 仍可覆盖。

具体实现时需要用 module priority 明确冲突规则，避免 `enabled` 列表和单项配置互相打架。

## System 层设计

计划结构：

```text
modules/system/base.nix
modules/system/nix.nix
modules/system/gc.nix
modules/system/fish-shell.nix
modules/system/helix.nix
```

### Nix 设置

`modules/system/nix.nix` 是必选基础模块，不需要 `enable`。

导入后总是设置：

```nix
nix.settings.experimental-features = [
  "nix-command"
  "flakes"
];
```

只暴露 host-specific 的额外 trusted users：

```nix
pixdane.system.nix.trustedUsers = [ "pixdane" ];
```

模块内部组合为：

```nix
nix.settings.trusted-users =
  [ "root" ] ++ config.pixdane.system.nix.trustedUsers;
```

`root` 总是包含。普通用户部分由 host 自己指定。

如果只有 standalone home-manager，这个设置不会生效，因为 home-manager 不能修改 Nix daemon 设置。只有 nix-darwin / NixOS 这种系统级 evaluation 才能管理它。

### GC 和 optimise

`modules/system/gc.nix` 是必选基础模块，不需要自定义 option。

导入后设置：

```nix
nix.gc = {
  automatic = true;
  options = "--delete-older-than 1w";
};

nix.optimise.automatic = true;
```

不设置平台调度参数：

```nix
nix.gc.dates
nix.gc.interval
nix.optimise.dates
nix.optimise.interval
```

这些使用 NixOS 和 nix-darwin 各自默认值。

GC 负责清理旧 generation 和不再被 GC roots 引用的 store paths。`optimise` 不删除内容，只对 Nix store 中相同内容的文件做 hard-link 去重。

NixOS 旧系统 generation 的清理包含在 `nix-collect-garbage --delete-older-than 1w` 这套机制里。`boot.loader.systemd-boot.configurationLimit` 是另一个问题，只控制启动菜单保留项数量。

### 系统 fish 支持

`modules/system/fish-shell.nix` 是可选 feature：

```nix
pixdane.system.fishShell.enable = true;
```

启用后：

```nix
programs.fish.enable = true;
```

Darwin 额外需要：

```nix
environment.shells = [
  pkgs.fish
];
```

NixOS 不额外写 `environment.shells`，因为 NixOS 的 `programs.fish.enable = true` 已经会把 fish 加入允许的 login shell 列表。

这个模块只负责系统层 fish 支持，不设置任何用户的默认 shell。

### 系统 Helix

Helix 需要作为系统编辑器使用。

`modules/system/helix.nix` 设计为：

```nix
pixdane.system.helix.enable = true;
```

启用后：

```nix
environment.systemPackages = [
  inputs.helix-flake.packages.${pkgs.system}.default
];

environment.variables = {
  EDITOR = "hx";
  VISUAL = "hx";
};
```

Helix 使用 upstream HEAD input `helix-flake`，不使用 `pkgs.helix`。

### 用户 shell

用户默认 login shell 不是 home-manager 配置，而是系统用户配置。

Darwin host 直接使用原生配置：

```nix
system.primaryUser = "pixdane";

users.users.pixdane = {
  home = "/Users/pixdane";
  shell = pkgs.fish;
};
```

NixOS host 也直接使用原生配置：

```nix
users.users.pixdane = {
  isNormalUser = true;
  description = "pixdane";
  extraGroups = [ "networkmanager" "wheel" ];
  shell = pkgs.fish;
};
```

不抽象 `users.users`，因为原生 option 已经准确表达机器用户事实，而且足够简洁。

默认不改变 root shell。root 仍然作为 Nix trusted user。

### stateVersion

`system.stateVersion` 是 host 事实，不包装成自定义 option。

现有值保持：

```nix
# Darwin
system.stateVersion = 6;

# NixOS
system.stateVersion = "25.05";
```

## Darwin 层设计

计划结构：

```text
modules/darwin/base.nix
modules/darwin/touch-id-sudo.nix
modules/darwin/homebrew.nix
modules/darwin/desktop.nix
modules/darwin/skhd.nix
modules/darwin/yabai.nix
modules/darwin/ubersicht.nix
modules/darwin/simple-bar.nix
```

### Darwin base

`system.primaryUser`、`users.users`、`nixpkgs.hostPlatform`、`networking.hostName` 等 host 事实直接写在 host 中，不包装成 `pixdane.*`。

### Touch ID sudo

Touch ID sudo 直接在 Darwin base 中打开，不再额外提供开关：

```nix
security.pam.services.sudo_local = {
  enable = true;
  reattach = true;
  touchIdAuth = true;
};
```

### Homebrew

Homebrew 是 nix-darwin 系统能力，不是 home-manager 能力。

Darwin base 打开：

```nix
homebrew.enable = true;
```

同时启用 shell integration：

```nix
homebrew.enableBashIntegration = true;
homebrew.enableZshIntegration = true;
homebrew.enableFishIntegration = true;
```

base 不放具体 taps、brews、casks。

activation 相关选项暂不调整，使用 nix-darwin 默认值：

- cleanup 默认不做主动清理。
- upgrade / autoUpdate 默认不主动升级。

Homebrew 安装是机器 prefix 级别的，不是每个 home-manager 用户各装一份。nix-darwin 的 `homebrew.user` 默认跟随 `system.primaryUser`。

### Window manager 总入口

Darwin desktop 使用一个聚合配置：

```nix
pixdane.darwin.windowManager = {
  backend = "yabai"; # "none" | "yabai"
  bar = "none";      # "none" | "simple-bar"

  yabai = {
    scriptingAddition.enable = false;
    config = { };
    extraConfig = "";
    unmanagedApps = [ ];
  };
};
```

暂不把 `sketchybar` 放进 `bar` enum，等实际恢复 sketchybar 时再加入。

`jankyborders` 直接删除，不进入新架构第一版。

### skhd

`modules/darwin/skhd.nix` 提供独立开关：

```nix
pixdane.darwin.skhd.enable = false;
```

启用后：

```nix
services.skhd.enable = true;
```

skhd 可以脱离 yabai 单独启动。

### yabai

`modules/darwin/yabai.nix` import `./skhd.nix`。

当：

```nix
pixdane.darwin.windowManager.backend = "yabai";
```

则：

- 启用 `services.yabai`。
- 用 `lib.mkDefault true` 默认打开 `pixdane.darwin.skhd.enable`。
- `services.yabai.enableScriptingAddition` 跟随 `pixdane.darwin.windowManager.yabai.scriptingAddition.enable`。
- scripting addition 默认关闭，因为需要额外关闭 SIP。

yabai config 采用“仓库默认 + bar padding + host override”的合并方式：

```nix
services.yabai.config =
  commonYabaiConfig
  // barPadding.${config.pixdane.darwin.windowManager.bar}
  // config.pixdane.darwin.windowManager.yabai.config;
```

bottom padding 跟随 bar：

```nix
{
  none = { bottom_padding = 4; };
  "simple-bar" = { bottom_padding = 44; };
}
```

host 可以用：

```nix
pixdane.darwin.windowManager.yabai.config = {
  # 覆盖或追加 yabai config
};
```

`extraConfig` 追加到生成配置之后。

`unmanagedApps` 默认空，由 host 写当前机器需要排除的 app：

```nix
pixdane.darwin.windowManager.yabai.unmanagedApps = [
  "系统设置"
  "QQ"
  "微信"
  "Raycast"
  "归档实用工具"
  "Microsoft To Do"
  "Steam"
];
```

第一版只根据 app 名生成 `manage=off` rule，不做更复杂的结构化 rule option。

旧 skhd 中与 yabai 直接相关的快捷键放进 `yabai.nix`。`services.skhd.skhdConfig` 是 `types.lines`，多个模块可以自动合并追加。

skhd mode header 跟随 bar：

```skhd
# bar = "none"
:: default
:: window
:: resize
```

```skhd
# bar = "simple-bar"
:: default : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh NOM black
:: window : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh WIN black
:: resize : ~/.config/ubersicht/widgets/simple-bar/lib/scripts/yabai-set-mode.sh RES black
```

### Übersicht

`modules/darwin/ubersicht.nix` 提供：

```nix
pixdane.darwin.ubersicht.enable = false;
```

启用后安装 cask：

```nix
homebrew.casks = [ "ubersicht" ];
```

Übersicht 的 home symlink 由 home 侧 `ubersicht.nix` 管理，不放在 simple-bar 里。

### simple-bar

`modules/darwin/simple-bar.nix` import `./ubersicht.nix`。

当：

```nix
pixdane.darwin.windowManager.bar = "simple-bar";
```

则默认打开：

```nix
pixdane.darwin.ubersicht.enable = lib.mkDefault true;
```

Darwin 侧只负责安装 Übersicht。simple-bar widget repo 和 `.simplebarrc` 由 home-manager 的 Darwin-only home 模块管理。

## Home 层设计

计划结构：

```text
modules/home/base.nix
modules/home/darwin-desktop.nix
modules/home/ubersicht.nix
modules/home/simple-bar.nix
modules/home/fish.nix
modules/home/git.nix
modules/home/helix.nix
modules/home/starship.nix
modules/home/direnv.nix
modules/home/zoxide.nix
modules/home/nix-your-shell.nix
modules/home/pay-respects.nix
modules/home/zellij.nix
modules/home/tools.nix
```

`modules/home/base.nix` import 所有公共 home feature 模块和 `home/darwin-desktop.nix`，但 feature 是否启用由 `pixdane.features.enabled` / `disabled` 决定。

### Darwin-only home desktop

`modules/home/darwin-desktop.nix` 负责按平台导入 Darwin-only home 模块：

```nix
imports = lib.optionals pkgs.stdenv.isDarwin [
  ./ubersicht.nix
  ./simple-bar.nix
];
```

因此 `home/ubersicht.nix` 和 `home/simple-bar.nix` 自己不再检查系统。

### home/ubersicht.nix

负责创建 symlink：

```text
~/.config/ubersicht -> ~/Library/Application Support/Übersicht
```

这个 symlink 属于 Übersicht 模块，不属于 simple-bar 模块。

### home/simple-bar.nix

只在 Darwin-only home desktop 被 import 后可用。

当 nix-darwin 侧选择：

```nix
osConfig.pixdane.darwin.windowManager.bar == "simple-bar"
```

则部署 simple-bar widget repo 到：

```text
~/Library/Application Support/Übersicht/widgets/simple-bar
```

并管理：

```text
~/.simplebarrc
```

simple-bar repo 作为 flake input 固定版本：

```nix
inputs.simple-bar = {
  url = "github:Jean-Tinland/simple-bar";
  flake = false;
};
```

需要保留一个 patch 点处理当前脚本问题。

已检查本机 simple-bar 状态：

- 本机路径：`/Users/pixdane/Library/Application Support/Übersicht/widgets/simple-bar`
- origin：`https://github.com/Jean-Tinland/simple-bar`
- branch：`master`
- HEAD：`7673cbb Update roadmap in README`
- working tree 有本地改动，主要涉及脚本 mode 和 `lib/scripts/init-yabai.sh`

`.simplebarrc` 当前在：

```text
/Users/pixdane/.simplebarrc
```

其中重要设置包括：

- `global.bottomBar = true`
- `global.windowManager = "yabai"`
- `global.shell = "dash"`
- `process.displaySkhdMode = true`
- 启用 widgets：process、netstats、cpu、memory、music

`init-yabai.sh` 的问题：

- simple-bar 会用 `.simplebarrc` 中的 shell 执行脚本。
- 当前 shell 是 `dash`。
- 上游脚本使用 `${BASH_SOURCE[0]}`，在 `dash` 下会失败。

更稳妥的 patch 方向是把脚本目录计算改成 POSIX-compatible：

```sh
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
```

然后继续用 sibling script：

```sh
"${SCRIPT_DIR}"/yabai-set-mode.sh
```

同时在 derivation/install 步骤里确保脚本可执行：

```sh
chmod +x "$out"/lib/scripts/*.sh "$out"/lib/scripts/*.applescript
```

这个 patch 先保留。重构完成后可以很容易地关掉 patch 再测试。

### fish

公共 `home/fish.nix` 只负责 fish 本体和共同体验：

```nix
programs.fish = {
  enable = true;
  shellAliases."..." = "cd ../..";
  plugins = [
    {
      name = "nix.fish";
      src = inputs.nix-fish;
    }
  ];
};
```

`nix.fish` 作为 flake input：

```nix
inputs.nix-fish = {
  url = "github:kidonng/nix.fish/ad57d970841ae4a24521b5b1a68121cf385ba71e";
  flake = false;
};
```

不再把其他软件的 shell integration 塞进 fish 模块：

- zellij integration 放 `zellij.nix`
- starship integration 放 `starship.nix`
- zoxide integration 放 `zoxide.nix`
- direnv integration 放 `direnv.nix`
- pay-respects integration 放 `pay-respects.nix`

`code = "open -a \"Visual Studio Code\""` 是 macOS 用户本地 alias，不进公共 fish。

Gaussian 相关环境变量和 `bass` 也留在 macOS 用户本地配置，不进公共 fish。`bass` 只为 Gaussian shell init 服务，不是公共依赖。

`~/.local/bin` 暂时不放公共 fish，也不急着放 `home.sessionPath`。后续可能用 Nix 安装 `uv`；如果这样做，为 `uv` 准备 `~/.local/bin` 的需求会消失。

### zellij

`zellij` 从 `tools` 中拆出独立模块。

设计为：

```nix
programs.zellij = {
  enable = true;
  enableFishIntegration = true;
};
```

实现前需要检查当前 Home Manager 的 `programs.zellij` 支持哪些 bash/zsh/fish integration option。不要凭记忆写不存在的 option。

### Helix

Helix 放在 home base feature 中，同时 system 层也可作为系统编辑器安装。

home 侧使用 upstream HEAD input：

```nix
programs.helix = {
  enable = true;
  package = inputs.helix-flake.packages.${pkgs.system}.default;
  defaultEditor = true;
};
```

保留旧配置中的 settings/theme。LaTeX support 旧模块存在，但暂不默认启用，之后单独讨论。

Helix 模块保留目录结构：

```text
modules/home/helix/default.nix
modules/home/helix/settings.nix
modules/home/helix/themes.nix
modules/home/helix/languages.nix
modules/home/helix/latex-support.nix
modules/home/helix/themes/catppuccin_mocha_modified.toml
```

`languages.nix` 第一版配置 Nix formatter。当前 `pkgs.nixfmt` 已经是 RFC style formatter：

```nix
programs.helix.languages.language = [
  {
    name = "nix";
    auto-format = true;
    formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
  }
];
```

repo 级 flake output 参考 Blueprint 的 `formatter.nix` 写法：使用 `writeShellApplication` 包装 formatter；无参数时默认定位 git 顶层；通过 `git ls-files` 遍历 repo 内的 Nix 文件；并附带 format check。formatter 包使用 `pkgs.nixfmt`。

VS Code 侧使用 Nix IDE 做 Nix formatter，设置方向是：

```json
{
  "[nix]": {
    "editor.defaultFormatter": "jnoortheen.nix-ide",
    "editor.formatOnSave": true
  },
  "nix.formatterPath": "nixfmt",
  "nix.enableLanguageServer": true,
  "nix.serverPath": "nixd"
}
```

Alejandra VS Code 插件不作为本 repo 的 formatter 使用。

### Git

公共 git 模块只放通用设置。

`userName` / `userEmail` 不放公共模块，应该写在 host 或用户本地配置中。

### Shell integration

shell integration 属于对应软件模块，不属于 fish 模块。

预期：

- starship：bash/zsh/fish integration 都打开。
- zoxide：bash/zsh/fish integration 都打开。
- direnv：bash/zsh/fish integration 都打开。
- pay-respects：bash/zsh/fish integration 都打开。
- zellij：按 Home Manager 当前支持情况打开。
- nix-your-shell：fish/zsh integration 打开；当前 Home Manager 模块没有 bash integration option。

### tools

`tools.nix` 放用户态基础工具和本仓库维护所需的轻量 Nix 工具。

初步包括：

```nix
xz
zstd
jq
fd
ripgrep
ncdu
yazi
lazygit
ouch
nixfmt
nixd
cachix
```

Darwin only：

```nix
dos2unix
```

Linux only：

```nix
zip
unzip
```

不放进 `tools` 的内容：

```nix
helix        # 单独模块，且 system 层也需要
zellij       # 单独模块
pay-respects # 单独模块，且会携带 nix-search-cli
zoxide       # 单独模块
fzf          # 第一版删除
typst        # Mac host local
dotnet-sdk_10 # Mac host local
ffmpeg       # Mac host local
mpv          # Mac host local
ntfs3g       # 第一版不恢复
```

`nix-search-cli` 不属于 `tools`。当前机器的 command-not-found 体验来自 `pay-respects`：

```text
fish command-not-found
-> pay-respects cnf
-> nix-search <missing-command>
```

因此 `nix-search-cli` 跟随 `payRespects` feature：

```nix
pixdane.features.payRespects.enable = true;

programs.pay-respects = {
  enable = true;
  enableBashIntegration = true;
  enableFishIntegration = true;
  enableZshIntegration = true;
};

home.packages = [
  pkgs.nix-search-cli
];
```

`fzf` 第一版删除，不做 `pixdane.features.fzf`，旧 `modules/home/fzf.nix` 后续实现时可以移除。`fd` 保留在 `tools`，因为它是独立的现代文件查找工具。

`typst`、`ffmpeg`、`mpv`、`dotnet-sdk_10` 不进入公共 home feature，改放当前 Mac host 的 home 配置中：

```nix
home.packages = with pkgs; [
  typst
  ffmpeg
  mpv
  dotnet-sdk_10
];
```

`ntfs3g` 第一版不恢复。当前机器上 Homebrew 和 Nix 两份 `ntfs-3g` 都会因为缺少 `/usr/local/lib/libfuse.2.dylib` 失败；修复需要 macFUSE/libfuse 和 macOS 系统扩展批准，后续如果确实需要 NTFS 写入，再作为 Darwin 系统层能力单独处理。

系统级和用户级的基本原则：

- 系统层放 shell 支持、系统编辑器、系统 service、window manager service 等。
- home-manager 放用户 CLI 工具和用户态配置。
- Helix 例外：既需要系统编辑器，也需要 home-manager 用户配置。

## NixOS 层待继续讨论

NixOS 短期不是主力，但结构要进入新系统。

旧配置中 NixOS VM 包含：

- systemd-boot
- `boot.loader.systemd-boot.configurationLimit = 10`
- NetworkManager
- Parallels VM proxy
- timezone 和 locale
- `users.users.pixdane`
- getty autologin
- `programs.vim.enable = true`
- `programs.nix-ld.enable = true`
- Parallels hardware config

这些需要拆分成：

```text
modules/nixos/base.nix
modules/nixos/vm.nix
```

哪些属于 shared NixOS base，哪些属于 `nixos-parallels` host local，后续继续定。

## 原 repo 中需要特别处理的旧状态

- `skhd` 依赖 Übersicht/simple-bar 的 mode script。
- `sketchybar` 配置目录完整，但 `programs.sketchybar.enable = false`。
- `sketchybarrc` 当前只加载 `spaces`、`yabai`、`front_app`。
- apple、battery、cpu、brew、github、spotify、calendar、volume 等 sketchybar item 更像库存功能，不应第一批全部恢复。
- sketchybar helper 会编译并启动 CPU helper，但当前 CPU item 未加载。
- repo 中提交了 Mach-O helper 二进制，重构时需要决定是否保留。
- `modules/home/sketchybar/config/items/volume.sh` 里 bracket 名称疑似旧 bug：添加的是 `status_bracket`，设置时用了 `status`。
- `jankyborders` 不进入新架构第一版。

## 后续顺序

已经讨论并记录的主题：

1. Blueprint 布局和 `prefix`。
2. 不新增顶层 `profiles/`。
3. module evaluation 边界。
4. system 层 Nix、GC、fish shell、Helix、用户 shell。
5. Darwin Touch ID sudo、Homebrew、window manager、yabai/skhd、Übersicht/simple-bar。
6. home feature 选择模型。
7. fish、nix.fish、shell integration 边界。
8. starship、direnv、zoxide、pay-respects、git、zellij。
9. tools、nixfmt、Helix formatter、VS Code Nix IDE formatter。
10. Mac host local 包：`typst`、`ffmpeg`、`mpv`、`dotnet-sdk_10`。
11. 第一版删除 `fzf`，第一版不恢复 `ntfs3g`。

建议后续继续按软件逐个讨论：

1. Helix LaTeX support 是否进入 `writing` 或保持本地关闭。
2. VS Code 是否由 Home Manager 管理 settings/extensions。
3. NixOS base / VM 拆分。
4. 是否开始按本文档实现第一批模块。
