# TODO

这个文件记录 full rework 之后还没有进入第一版实现的主题。架构状态见 `docs/architecture/full-rework.zh.md`。

## VS Code

- Decide whether VS Code should stay unmanaged, use repo-local settings only, or be managed by Home Manager.
- If Home Manager manages it, decide whether to manage settings only or extensions as well.
- Current direction recorded in the architecture doc: Nix IDE should use `nixfmt`; Alejandra is not the repo formatter.
- `.vscode/` is ignored and should stay local unless this decision changes.

## Helix LaTeX

- Decide whether `modules/home/helix/latex-support.nix` should become a real feature, move to a writing/document module, or remain a local legacy candidate.
- Decide tool ownership before enabling it: Nix packages, MacTeX, or other external tools.
- Current assumptions in the legacy module include `tex-fmt`, `texlab`, `latexmk`, and the macOS Skim forward-search path.

## Zellij

- Current implementation enables `programs.zellij` and fish integration.
- Revisit shell integration after checking the current Home Manager `programs.zellij` options.
- Decide whether zellij needs shared defaults beyond the current minimal setup.
- Keep zellij separate from `tools`.

## WezTerm

- Decide whether WezTerm should be managed by Home Manager, nix-darwin/Homebrew, or left local.
- If managed, decide where it belongs:
  - system/Darwin app installation
  - home terminal configuration
  - shell integration with fish/starship/zellij
- Check existing local WezTerm config before designing the module.

## NixOS

- Keep NixOS structurally supported, but macOS remains the active target.
- Split reusable VM or desktop behavior out of `hosts/nixos-parallels/configuration.nix` only when another NixOS host or real usage justifies it.
- Candidate future module: `modules/nixos/vm.nix`.
- Current NixOS base keeps shared basics only: boot generation limit, vim, nix-ld, and system packages such as git, Helix, vim, and wget.
