[English](README.md) | 中文

# riscdom-adminapp

**RiscDom 管理程序** —— 驱动一个 RiscDom 节点与控制平面的桌面应用（并将在未来扩展出
移动端与浏览器形态）。

本仓是三仓之一。内核是
[`breakevery/riscdom`](https://github.com/breakevery/riscdom) —— 沙箱、审计链、agent 循环、
连接层与 host core。作为程序的控制平面是
[`breakevery/riscdom-server`](https://github.com/breakevery/riscdom-server) —— HTTP + SSE 服务端。
**本仓是人真正使用的那个程序**：Tauri 外壳与 React 前端。

> **状态。** `v1.0.0`。自内核拆出即 **M8-4b**；本仓承载前端（在仓库根）与 Tauri 外壳 crate
> （`host-tauri/`）。

## 这里有什么

```text
riscdom-adminapp/
├── Cargo.toml            # workspace：只含 `host-tauri`；`src-tauri` 独立构建
├── host-tauri/           # Tauri 外壳：命令 / 事件 / 状态（host-core 之上的门面）
├── src/                  # React 前端（layout / panels / API / state）
├── src-tauri/            # Tauri 应用 crate（注册 host-tauri 的命令）
├── scripts/              # gate、探针、守卫
├── index.html, vite.config.ts, tsconfig*.json
├── CLA.md                # 本仓自带的 CLA 与签署库
└── .github/workflows/    # ci.yml（gate / bundle / secrets）、cla.yml
```

前端位于**仓库根**（它曾是内核里的 `ui/`）。`src-tauri/` 是一个**独立** crate —— 不属
workspace，因为 Tauri 的构建需要它自己的 lock 文件 —— 它依赖：

- `host-tauri`：**path**（`../host-tauri`），本仓内的 crate；
- `server`：来自 **`riscdom-server` 的 `v1.0.0` tag**（git 依赖），即外壳在进程内启动、好让手机
  也能访问该节点的那个控制平面。

`host-tauri` 反过来依赖内核的 `host-core` 与 `net`，来自**内核的 `v1.0.0` tag**。每个上游仓一个
tag，且 `Cargo.lock` 已提交：tag 会移动，提交的 lock 不会。

## 要求

- **Rust**（含 `rustfmt` + `clippy`），Windows 上还需 **MSVC 工具链**（Tauri 需要）。
- **Node / npm** —— Node 22.6 或更新（探针直接 import `.ts`、依赖类型剥离；23.6 起默认）。
- **Linux** 另需 WebKitGTK 及其伙伴（`libwebkit2gtk-4.1-dev`、`libgtk-3-dev`、`librsvg2-dev`、
  `libsoup-3.0-dev`、`libayatana-appindicator3-dev`）与 `libdbus-1-dev`（内核的 `keyring` 后端）。

## 构建与运行

```sh
# 1. 前端依赖
npm ci

# 2. 启动桌面应用（会编译 Rust 后端）
npm run tauri dev
```

在设置里指向一个模型提供方后（自带密钥，或用本地模型如 Ollama / LM Studio —— 无需密钥），让 agent
端到端做一件事，例如：*「写一个 RISC-V 裸机 Hello World，编译、运行并读回串口输出」*。

## 测试

```sh
# gate：「绿」的唯一清单（CI 跑同一个文件）
sh scripts/gate.sh

# 单独跑外壳 crate
cargo test -p host-tauri

# 前端构建
npm run build
```

gate 会跑前端构建、`host-tauri` 与 `src-tauri` 的 lint 与 check，以及 **17 个 UI 回归探针**。其中
4 个探针读取位于内核的源码（拆仓把它们移走了）；每一个都会打印带原因的 **SKIP** 而不是失败，跨仓
校验将在 **M8-4d** 回归。

## 安全声明

- 本程序**不提供、不托管、不内嵌**任何 API key。所有模型访问均为自带密钥（BYOK）。
- API key 留在你的机器上（默认在 OS keyring），**绝不经过本项目任何服务器**。
- 本程序**绝不**上传你的代码、串口输出或审计日志。

## 贡献

请先读 [CONTRIBUTING.md](CONTRIBUTING.md)：每次改动都必须通过本地 gate（`scripts/gate.sh`）并走
pull request。请签署 [CLA](CLA.md) —— 本仓自带其自己的。

## 许可证

[Apache License 2.0](LICENSE)。QEMU 与任何下载的 RISC-V 工具链都是独立程序、各自许可；由用户安装，
本仓从不打包它们。
