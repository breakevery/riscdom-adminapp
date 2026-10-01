[English](CONTRIBUTING.md) | 中文

# 贡献指南

感谢你对 RiscDom 的关注。本仓是**管理程序** —— 驱动一个 RiscDom 节点与控制平面的桌面应用
（Tauri 外壳 + React 前端）。它一步一步构建，每一步都必须可验证、可回滚 —— 贡献遵循同样的纪律。

内核是 [`breakevery/riscdom`](https://github.com/breakevery/riscdom)；作为程序的控制平面是
[`breakevery/riscdom-server`](https://github.com/breakevery/riscdom-server)。每个仓跑自己的
gate；本仓只检查本仓的东西。

## 开发环境

- **Rust / cargo**（含 `rustfmt` + `clippy`），Windows 上还需 **MSVC 工具链**（Tauri 需要）。
- **Node / npm** —— Node 22.6 或更新（探针 import `.ts`、依赖类型剥离；23.6 起默认）。
- **Linux** 另需 WebKitGTK 及其伙伴（`libwebkit2gtk-4.1-dev`、`libgtk-3-dev`、`librsvg2-dev`、
  `libsoup-3.0-dev`、`libayatana-appindicator3-dev`）与 `libdbus-1-dev`（内核的 `keyring` 后端）。
- **QEMU 与 RISC-V 裸机 GCC** 是*节点*的依赖，不是本仓的构建依赖：应用驱动一个节点，而用户为那个
  节点安装 QEMU。本项目从不打包或下载它们。

**绝不用 PowerShell 读写源码文件。** 用编辑器或 agent 的 `edit` / `write`，UTF-8 无 BOM：Windows
PowerShell 5.1 会把无 BOM 的 UTF-8 文件按 ANSI 代码页解码再编码，把 em dash 变成 `U+9225` 外加一
个丢掉的字节。PowerShell 只用于*命令*（`git`、`gh`、`cargo`、`npm`、`node`）。

## 本地检查（gate）

每次提交前跑 gate：

```text
sh scripts/gate.sh      # Unix
```

（Windows 上通过 Git 的 `sh.exe` 跑同一个文件。）

gate 是**「绿」的唯一清单**：CI 跑同一个文件（`.github/workflows/ci.yml` 里的
`sh scripts/gate.sh`），所以检查不会在 CI 与开发机之间漂移。顺序为：`cargo fmt --all -- --check`
→ `cargo clippy -D warnings`（`host-tauri` workspace 与 `src-tauri`）→ `cargo test` →
`cargo check` → `npm run build` → 17 个 UI 回归探针（`node scripts/probe-ui-*.mjs`）→
ui 字符串注册表守卫（`node scripts/check-ui-strings.mjs`）→ wix 版本守卫
（`node scripts/check-wix-version.mjs`）。

17 个探针里有 4 个读取被拆仓移到内核仓的源码。每一个都打印带原因的 **SKIP** 而不是失败；跨仓校验
将在 **M8-4d** 回归。

## 提交信息

**能自己先跑 gate 就先跑** —— 本仓没有提交包装器（内核的 `scripts/commit.ps1` 留在了内核）；纪律
不变：跑 `sh scripts/gate.sh`，绿了才提交。

`type: subject`，`type` 取 `feat` / `fix` / `docs` / `test` / `chore` / `refactor` / `perf` /
`build` / `ci` 之一。subject 用祈使语气，控制在约 70 字符内。

### 让信息保持 ASCII —— Windows 上 `-m` 是有损的

在 Windows 上，用中文写、并作为 `git commit -m "…"` 传入的信息**永远无法完整到达 commit 对象**：
命令行要穿过控制台的 ANSI 代码页，于是每个非 ASCII 字符在 git 看到之前就被替换成 `?`（`0x3F`）。
所以 `-m` 信息请用 **ASCII（英文）** —— 本仓的惯例；当信息必须含非 ASCII 文本时，把它写成 UTF-8
无 BOM 的文件，用 `git commit -F <file>`。

## 贡献者许可协议（CLA）

**若你要向本仓贡献，在 pull request 被合并之前你需要接受 [CLA](CLA.md)。** 每个仓自带其自己的
CLA 与签署库。签署方式：在该 pull request 下评论**恰好**下面这句英文：

```text
I have read the CLA Document and I hereby sign the CLA
```

[CLA Assistant](.github/workflows/cla.yml) 机器人会校验并把签署记录写入
[`signatures/version1/cla.json`](signatures/version1/cla.json)。作者未签署的 pull request 不会被
合并。微小改动（错别字、失效链接）可不经签署直接接受 —— CLA.md §9。

## Pull request

1. Fork 本仓（或有写权限时建分支）。
2. 保持改动范围收敛；不要碰无关文件。
3. 本地跑 gate。**每个 pull request 都必须在 CI 通过 gate。**
4. 说明改了什么、如何验证、以及任何残留限制。
5. CLA 检查必须为绿 —— 见上。

## 绝不提交

- 任何 API key、token 或凭据（本项目为 BYOK，自带密钥，不打包任何 key）
- 构建产物：`target/`、`node_modules/`、`dist/*`、`.env*`

`.gitignore` 已覆盖大部分；CI 还会跑密钥扫描（gitleaks，全历史）。

## 文档

文档双语：英文文件是主文档，中文译文以 `*.zh-CN.md` 放在旁边，首行是语言切换器：

```markdown
[中文](README.zh-CN.md) | English
```

代码块、命令、路径、配置键与 API 名保持不译。
