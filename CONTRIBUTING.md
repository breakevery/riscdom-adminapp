[中文](CONTRIBUTING.zh-CN.md) | English

# Contributing

Thanks for your interest in RiscDom. This repository is **the management program** — the desktop
application (Tauri shell + React front end) that drives a RiscDom node and a control plane. It is
built step by step, and every step must be verifiable and rollback-able — contributions follow the
same discipline.

The kernel is [`breakevery/riscdom`](https://github.com/breakevery/riscdom); the control plane as a
program is [`breakevery/riscdom-server`](https://github.com/breakevery/riscdom-server). Each
repository runs its own gate; this one checks only what is here.

## Development environment

- **Rust / cargo** with `rustfmt` + `clippy`, and the **MSVC toolchain** on Windows (Tauri needs it).
- **Node / npm** — Node 22.6 or newer (the probes import `.ts` and rely on type stripping; default
  from Node 23.6).
- **Linux** additionally needs WebKitGTK and its neighbours (`libwebkit2gtk-4.1-dev`,
  `libgtk-3-dev`, `librsvg2-dev`, `libsoup-3.0-dev`, `libayatana-appindicator3-dev`) and
  `libdbus-1-dev` (the kernel's `keyring` backend).
- **QEMU and a RISC-V bare-metal GCC** are the *node's* dependencies, not this repository's build
  dependencies: the app drives a node, and it is the node the user installs QEMU for. They are
  never bundled or downloaded by this project.

**Never read or write a source file with PowerShell.** Use your editor's or agent's `edit` /
`write` path, as UTF-8 without a BOM: Windows PowerShell 5.1 decodes a BOM-less UTF-8 file as the
ANSI code page and re-encodes it, turning an em dash into `U+9225` plus a lost byte. PowerShell is
for *commands* (`git`, `gh`, `cargo`, `npm`, `node`).

## Local checks (the gate)

Run the gate before every commit:

```text
sh scripts/gate.sh      # Unix
```

(On Windows, run the same file through Git's `sh.exe`.)

The gate is the **single list of what "green" means**: CI runs the same file
(`sh scripts/gate.sh` in `.github/workflows/ci.yml`), so a check cannot drift between CI and a
developer machine. In order: `cargo fmt --all -- --check` → `cargo clippy -D warnings` for the
`host-tauri` workspace and for `src-tauri` → `cargo test` → `cargo check` → `npm run build` → the
seventeen UI regression probes (`node scripts/probe-ui-*.mjs`) → the ui string registry guard
(`node scripts/check-ui-strings.mjs`) → the wix-version guard
(`node scripts/check-wix-version.mjs`).

Four of the seventeen probes read kernel sources that the split moved to the kernel repository.
Each prints a **SKIP** with its reason instead of failing; the cross-repository checks return with
**M8-4d**.

## Commit messages

**Do not call `git commit` directly** if you can run the gate yourself first — this repository has
no commit wrapper (the kernel's `scripts/commit.ps1` stayed with the kernel); the discipline is
the same: run `sh scripts/gate.sh` and only commit when it is green.

`type: subject`, where `type` is one of `feat` / `fix` / `docs` / `test` / `chore` / `refactor` /
`perf` / `build` / `ci`. Write the subject in the imperative mood and keep it under about 70
characters.

### Keep the message ASCII — the `-m` path is lossy on Windows

A message written in Chinese and passed as `git commit -m "…"` never reaches the commit object
intact on Windows: the command line crosses the console's ANSI code page, so every non-ASCII
character is replaced by `?` (`0x3F`) before git sees it. So write `-m` messages in **ASCII
(English)** — the norm in this repository — and when a message must contain non-ASCII text, write
it to a file as UTF-8 without BOM and use `git commit -F <file>`.

## Contributor License Agreement (CLA)

**If you contribute to this repository, you need to accept the [CLA](CLA.md) before a pull request
can be merged.** Each repository carries its own CLA and its own signature store. Sign it by
commenting on the pull request with exactly this sentence, **in English**:

```text
I have read the CLA Document and I hereby sign the CLA
```

The [CLA Assistant](.github/workflows/cla.yml) bot verifies the signature and records it in
[`signatures/version1/cla.json`](signatures/version1/cla.json). A pull request whose author has not
signed is not merged. A trivial fix (a typo, a broken link) may be accepted without a signature —
CLA.md §9.

## Pull requests

1. Fork the repository (or create a branch if you have write access).
2. Keep the change scoped; do not touch unrelated files.
3. Run the gate locally. **Every pull request must pass the gate in CI.**
4. Describe what changed, how you verified it, and any residual limits.
5. The CLA check must be green — see the section above.

## Never commit

- API keys, tokens or credentials of any kind (this project is BYOK and ships no key)
- build outputs: `target/`, `node_modules/`, `dist/*`, `.env*`

`.gitignore` already covers most of this; CI also runs secret scanning (gitleaks, full history).

## Documentation

Docs are bilingual: the English file is the main document and the Chinese translation lives
alongside it as `*.zh-CN.md`, with a language switcher on the first line:

```markdown
[中文](README.zh-CN.md) | English
```

Keep code blocks, commands, paths, configuration keys and API names untranslated.
