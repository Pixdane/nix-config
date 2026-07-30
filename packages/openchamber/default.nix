{
  pkgs,
}:
let
  inherit (pkgs)
    lib
    stdenv
    fetchurl
    buildNpmPackage
    nodejs_22
    sqlite
    libutempter
    ;
  version = "1.17.1";
in
buildNpmPackage {
  pname = "openchamber";
  inherit version;

  # 发布到 npm 的 tarball 已预构建前端（dist/ + server/ + bin/ + public/），
  # 仅需拉取并编译原生依赖。
  src = fetchurl {
    url = "https://registry.npmjs.org/@openchamber/web/-/web-${version}.tgz";
    hash = "sha256-zBi62SL035LBH7q8/yM6Sf9n53R348O9PzTY7M9OY6c=";
  };

  # npm 包未随附 lockfile，此处注入本地生成的 package-lock.json。
  # fetchNpmDeps 与主构建都会经 postPatch 得到该文件。
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  # 依赖图哈希（由 prefetch-npm-deps 计算，首次构建回填）。
  npmDepsHash = "sha256-84wwjyqi5u8YmEy9FzrbkXx1hS7AOTNIAMLNTt/Rx3g=";

  # 运行时与构建期统一使用 Node.js 22（上游要求 Node.js 22+）。
  nodejs = nodejs_22;

  # 原生模块（better-sqlite3 / node-pty / bun-pty）的编译输入。
  # nodejs.python 由 buildNpmPackage 自动注入；macOS 的 cctools 同理。
  nativeBuildInputs = [
    nodejs_22
    sqlite
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libutempter;

  buildInputs = [
    sqlite
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libutempter;

  # 发布包已预构建前端，跳过 `npm run build`。
  dontNpmBuild = true;

  # 避免 install 阶段 npm 对 peer deps 过严导致失败。
  npmFlags = [ "--legacy-peer-deps" ];

  # 确保 bin 入口可执行并修复 shebang。
  postInstall = ''
    patchShebangs $out/lib/node_modules/@openchamber/web/bin/cli.js
  '';

  meta = {
    description = "Web/desktop/mobile GUI for OpenCode - server (Express)";
    homepage = "https://github.com/openchamber/openchamber";
    license = lib.licenses.mit;
    mainProgram = "openchamber";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
