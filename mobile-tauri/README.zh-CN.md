[English](README.md) | 中文

# `mobile-tauri` —— RiscDom 移动端外壳

一个小的 Tauri 2 crate，把**前端构建产物**（`../dist/app`）放进 webview，于是手机跑的是与桌面壳、
浏览器**同一套 React 应用**。它是本项目的 Android 之家（批 ED-8）；iOS 是后续批次。

**它既不链接内核、也不链接控制平面。** 它的依赖清单只有 `tauri`、`serde`、`serde_json` —— 没有
`host-tauri`、没有 `host-core`、没有 `net`、没有 `server`。手机经 HTTP 连一个 `riscdom-server`，而
前端构建里的 `api/http.ts` 就是那条传输。桌面壳（`../src-tauri`）确实带那些边，因为那里节点就在同一个
进程里，而手机没有节点。

| | `../src-tauri`（桌面） | `mobile-tauri`（本仓） |
|---|---|---|
| 传输 | 到内嵌宿主的 Tauri IPC，或 `remote` 模式的 HTTP | 仅 HTTP |
| 内核 / 控制平面 | `host-tauri` + `server` | 两者皆无 |
| 写操作 | 有（它就是那个节点） | 无 —— 浏览器面是只读的 |

## 构建

构建需要 Android 工具链（JDK 17+、Android SDK 与 NDK），而**本机没有** —— 见 `../README.zh-CN.md`
的「移动端」一节。装好之后：

```bash
npm install
npm run tauri:android:build     # -> mobile-tauri/gen/android/app/build/outputs/apk/**/*.apk
```

`tauri android init`（批 ED-9）会生成 `gen/android`；它目前尚未提交，所以这两个脚本在它生成之前跑不起来。

`frontendDist` 是 `../dist/app`，与桌面壳同一个目录 —— 前端**一份构建**服务所有壳，外加服务端的
`--web-root`。
