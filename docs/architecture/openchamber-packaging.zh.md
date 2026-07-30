# OpenChamber Server Nix 打包计划

> 目标：在本 nix-config（Numtide Blueprint + nix-darwin/NixOS + home-manager）仓库内，
> 为 [openchamber](https://github.com/openchamber/openchamber) 的 **web server**（npm 包
> `@openchamber/web`）制作一份可复现的 Nix 打包，并以可选项形式集成进 Home Manager。

---

## 1. 背景与现状

### 1.1 目标软件

OpenChamber 是 OpenCode AI agent 的跨端 GUI。其 **server** 即 npm 包
`@openchamber/web`（当前版本 `1.17.1`）：

- **运行时**：Node.js 22+（裸 Node 即可，Bun 仅开发期/CI 用）。
- **入口**：`bin/cli.js`（`openchamber` 命令），子命令 `serve` / `stop` / `update` /
  `tunnel` / `startup enable|disable|status`。
- **预构建产物**：发布到 npm 的 tarball 已包含 `dist/`、`server/`、`bin/`、`public/`，
  **无需**安装期再跑 `vite build`。
- **原生依赖**（关键约束）：`better-sqlite3`、`node-pty`、`bun-pty` 均含原生模块，
  需针对目标 Node ABI 编译。
- **可选依赖**：`sherpa-onnx-node`（语音，体积大、可按需）。

### 1.2 nixpkgs / 工具链可用性（已验证）

| 资源 | 状态 |
|---|---|
| `buildNpmPackage` | ✅ nixpkgs-unstable 提供 |
| `nodejs_22` | ✅ `nodejs-22.23.1` |
| `bun` | ✅ `bun-1.3.13`（仅在 build 期可能用到） |
| `buildBunPackage` | ❌ 尚未上游（不依赖它） |
| `better-sqlite3` / `node-pty` / `bun-pty` 单独打包 | ❌ 均不在 nixpkgs（需随主包一并编译） |

### 1.3 本仓库现状（已核对）

- Blueprint flake，系统：`aarch64-linux` / `aarch64-darwin` / `x86_64-linux` /
  `x86_64-darwin`。
- **尚无 `packages/` 目录** —— 这是首个自建 derivation。
- 模块以 `modules/{system,darwin,nixos,home}/...` 组织；Home 能力走
  `pixdane.features.*`（见 `modules/home/features.nix`）。
- 现有自建样本：`modules/home/window-manager/simple-bar/default.nix` 用
  `stdenvNoCC.mkDerivation` + `inputs.simple-bar` 做源，提供风格参考。
- 用户包通过 `home.packages` 增量添加（如
  `hosts/Pixdanes-MateBook-Pro/users/pixdane/home-configuration.nix`）。
- 文档为中文。

---

## 2. 设计决策

### 2.1 打包路径：`buildNpmPackage`（非 `buildBunPackage`）

**选择**：用 nixpkgs 的 `buildNpmPackage` 从 npm registry 拉取 `@openchamber/web`
并编译原生模块。

**理由**：
- 发布包预构建了前端，安装期无需 Bun/Vite，`buildNpmPackage` 是最贴合的构建器。
- `buildBunPackage` 尚未上游；项目虽用 Bun 做 monorepo 管理，但 runtime 是 Node。
- 原生模块（`better-sqlite3`/`node-pty`/`bun-pty`）必须针对 Node 22 ABI 编译，
  `buildNpmPackage` 的 `npmRebuildFlags` / `dontNpmBuild` 流程正好覆盖。

### 2.2 源：npm tarball（非 git）

用 `fetchurl` 拉取 `https://registry.npmjs.org/@openchamber/web/-/web-<ver>.tgz`，
配 `package-lock`/`npmDepsHash` 锁定依赖图。**不**从 GitHub 源码构建，避免引入
整个 monorepo + Bun 构建 + Vite 前端构建链路（超出“打包 server”范围且脆弱）。

### 2.3 版本与更新

- 单文件常量 `version`，便于一键 bump。
- 提供 `passthru.updateScript`（`nix-update` 或自写脚本查 npm registry），
  命中 `nix flake update`-friendly 的工作流。
- `bun-pty`/`node-pty` 二选一即可运行（`createTerminalRuntime` 按运行时动态选择）。
  打包时把两者都编译，保证 Node 与 Bun 运行时都可用。

### 2.4 暴露形式：Blueprint `packages/` + 可选 Home 模块

两层产物：

1. **纯包**：`packages/openchamber/default.nix` —— Blueprint 自动暴露为
   `packages.${system}.openchamber`（并生成 `checks.pkgs-openchamber`）。
2. **Home 集成**（可选、默认关闭）：`modules/home/cli/openchamber.nix`，
   通过新增 feature `openchamber` 接入 `pixdane.features.*` 体系，向
   `home.packages` 注入包并提供少量 `programs.openchamber`-风格配置入口。

> 说明：原生模块跨平台编译对 `aarch64-darwin` / `x86_64-linux` 均成立；
> `node-pty`/`better-sqlite3` 在 macOS/Linux 均有上游支持。
> `meta.platforms` 先设为 `linux` + `darwin`，若 `sherpa-onnx-node` 在某架构
> 失败再以 `optionalDependencies` 剥离并收窄平台。

---

## 3. 文件清单与结构

```
nix-config/
├─ packages/
│  └─ openchamber/
│     ├─ default.nix        # 主 derivation（buildNpmPackage）
│     └─ package-lock.json  # 从 @openchamber/web 拉取并提交，供 npmDepsHash 校验
├─ modules/home/cli/
│  └─ openchamber.nix       # Home feature：装包 + 可选配置
└─ docs/architecture/
   └─ openchamber-packaging.zh.md  # 本文件
```

Blueprint 会自动把 `packages/openchamber/default.nix` 注册为
`inputs.self.packages.${system}.openchamber`；无需手改 `flake.nix`。

---

## 4. 主 Derivation 草案

`packages/openchamber/default.nix`：

```nix
{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
  python3,
  pkg-config,
  # 以下原生依赖的构建期输入（better-sqlite3 / node-pty 需要）
  sqlite,
  # node-pty 在 Linux 需 utempter；macOS 用系统 tty
  utempter ? null,
}:
let
  version = "1.17.1";
in
buildNpmPackage {
  pname = "openchamber";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@openchamber/web/-/web-${version}.tgz";
    hash = lib.fakeSha256; # 首次构建后由 nix 填回真值
  };

  # 锁依赖图：提交 package-lock.json 后用
  # `nix run nixpkgs#nixPrefetch -- --build-npm-package ./packages/openchamber` 等方式生成
  npmDepsHash = lib.fakeHash;

  # 关键：用 Node 22 而非默认 Node
  nodejs = nodejs_22;

  # 原生模块编译依赖
  nativeBuildInputs = [
    python3
    pkg-config
    nodejs_22
  ] ++ lib.optional stdenv.isLinux utempter;

  buildInputs = [
    sqlite
  ] ++ lib.optional stdenv.isLinux utempter;

  # 发布包已预构建前端，不需要再跑 build 脚本
  dontNpmBuild = true;
  # 但仍需 rebuild 原生模块（better-sqlite3 / node-pty / bun-pty）
  npmRebuildFlags = [ ];

  # 防止 install 阶段触发上游 postinstall（patch-package 等）造成非确定性
  # 如确需 patch-package，在 patches = [...] 中以 Nix 方式应用
  npmFlags = [ "--legacy-peer-deps" ];

  # 产物：bin/cli.js 作为可执行入口
  postInstall = ''
    patchShebangs $out/lib/node_modules/@openchamber/web/bin/cli.js
  '';

  meta = with lib; {
    description = "Web/desktop/mobile GUI for OpenCode — server (Express)";
    homepage = "https://github.com/openchamber/openchamber";
    license = licenses.mit;
    mainProgram = "openchamber";
    platforms = platforms.linux ++ platforms.darwin;
    # 原生模块较重，仅维护者主动支持的主流架构
    badPlatforms = [];
  };
}
```

> 注：`stdenv` 需在参数列表显式引入（上方省略以聚焦结构）。`utempter` 仅 Linux 需要。

### 4.1 已知风险与对应处理

| 风险 | 影响 | 处理 |
|---|---|---|
| `better-sqlite3` 链接系统 sqlite 版本不匹配 | 运行时崩溃 | 优先让其 vendored sqlite 编译；必要时在 `preBuild` 设 `npm_config_build_from_source=true` |
| `node-pty` 在 NixOS 找不到 `/usr/bin` 的 shell | PTY 启动失败 | 运行期依赖：通过 wrapper 设 `SHELL=${runtimeShell}`，并在文档注明 |
| `bun-pty` 在纯 Node 环境实际不加载 | 多余构建成本 | 保留编译以满足 Bun runtime；若体积/构建时间成问题，改为 `optionalDependencies` 剥离 |
| `sherpa-onnx-node` 体积大、平台敏感 | 拖慢/失败构建 | 作为可选：`passthru.withVoice` 变体或 `optionalDependencies` |
| `postinstall`（patch-package）破坏纯度 | 构建不确定 | 用 Nix `patches` 替代；禁用上游 postinstall |
| npm `engines` 未声明但实际需 Node 22 | 默认 Node 版本错配 | 显式 `nodejs = nodejs_22` |

---

## 5. Home 集成草案

`modules/home/cli/openchamber.nix`：

```nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  enabled = config.pixdane.features.openchamber.effectiveEnabled;
  cfg = config.pixdane.openchamber or { };
  pkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.openchamber;
in
{
  # 1) 在 features.nix 的 featureNames 列表追加 "openchamber"
  # 2) 注入 home.packages
  config = lib.mkIf enabled {
    home.packages = [ pkg ];
  };
}
```

随后：

1. 在 `modules/home/features.nix` 的 `featureNames` 末尾加 `"openchamber"`。
2. 在 `modules/home/cli/default.nix` 的 `imports` 加 `./openchamber.nix`。
3. 主机按需开启，例如
   `hosts/Pixdanes-MateBook-Pro/users/pixdane/home-configuration.nix` 的
   `pixdane.features.enabled` 追加 `"openchamber"`。

---

## 6. 实施步骤（分阶段）

### 阶段 0 · 准备（~10 min）
- [ ] 确认 `@openchamber/web@1.17.1` tarball 的 `hash` 与 `npmDepsHash`
      （先 `lib.fakeSha256`/`lib.fakeHash`，构建报错回填真值）。
- [ ] 拉取 `package-lock.json` 放入 `packages/openchamber/`。

### 阶段 1 · 纯包构建（核心）
- [ ] 新建 `packages/openchamber/default.nix`（按第 4 节草案）。
- [ ] `nix build .#packages.aarch64-darwin.openchamber`（本机 darwin）。
- [ ] 修正 hash、原生模块编译参数，直至构建通过。
- [ ] `nix run .#packages.aarch64-darwin.openchamber -- --version` 冒烟。

### 阶段 2 · 运行时验证
- [ ] `./result/bin/openchamber serve --port 3001 --ui-password test`。
- [ ] 浏览器访问 UI、验证 sqlite 会话存储、PTY 终端可用。
- [ ] Linux 侧（nixos-parallels/sukumizu）交叉构建并验证 `node-pty`。

### 阶段 3 · Home 集成
- [ ] 新增 `modules/home/cli/openchamber.nix`。
- [ ] `features.nix` 注册 feature；`cli/default.nix` 导入。
- [ ] 在至少一台主机开启 feature，`darwin-rebuild switch` 验证。

### 阶段 4 · 收尾
- [ ] `nix fmt`（deadnix + nixfmt，见 `formatter.nix`）。
- [ ] `nix flake check`（确认 `checks.pkgs-openchamber` 绿）。
- [ ] 更新 `codemap.md` 增加 `packages/` 条目。
- [ ] 本文件即为文档（已落位 `docs/architecture/openchamber-packaging.zh.md`）。

---

## 7. 验证清单（成功标准）

- [ ] `nix build .#packages.<system>.openchamber` 在 `aarch64-darwin` 与
      `x86_64-linux` 均成功。
- [ ] `openchamber --version` 输出 `1.17.1`。
- [ ] `openchamber serve` 可起 HTTP 服务，UI 可访问，终端 PTY 可交互。
- [ ] `nix flake check` 通过（含 Blueprint 自动生成的 `pkgs-openchamber` check）。
- [ ] 开启 feature 的主机 rebuild 后 `which openchamber` 指向 Nix store 路径。

---

## 8. 后续可选增强（非本次范围）

- **NixOS module**：`modules/nixos/openchamber.nix` 提供 `systemd.services.openchamber`
  托管，对应上游 `startup enable` 语义。
- **nix-darwin module**：`launchd` 服务等价物。
- **Docker/Nix container**：`pkgs.dockerTools.buildImage` 镜像，替代上游 Dockerfile。
- **`withVoice` 变体**：把 `sherpa-onnx-node` 纳入的可选 passthru。
- **自建 `buildBunPackage`** 上游化（长期）。
