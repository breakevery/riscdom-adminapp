[中文](README.zh-CN.md) | English

# `mobile-tauri` — the RiscDom mobile shell

A small Tauri 2 crate that puts the **web build** (`../dist/app`) into a webview, so a
phone runs the same React application the desktop shell and a browser do. It is the
Android home of the project (batch ED-8); iOS is a later batch.

**It links neither the kernel nor the control plane.** Its whole dependency list is
`tauri`, `serde` and `serde_json` — no `host-tauri`, no `host-core`, no `net`, no
`server`. A phone reaches a `riscdom-server` over HTTP, and the web build's
`api/http.ts` is that transport. The desktop shell (`../src-tauri`) does carry those
edges, because there the node is in the same process, and a phone has no node.

| | `../src-tauri` (desktop) | `mobile-tauri` (this) |
|---|---|---|
| Transport | Tauri IPC to an embedded host, or HTTP in `remote` mode | HTTP only |
| Kernel / control plane | `host-tauri` + `server` | neither |
| Writes | yes (it is the node) | no — the browser face is read-only |

## Building

The build needs the Android toolchain (JDK 17+, Android SDK and NDK), which **this
machine does not have** — see `../README.md` § Mobile. Once it does:

```bash
npm install
npm run tauri:android:build     # -> mobile-tauri/gen/android/app/build/outputs/apk/**/*.apk
```

`tauri android init` (batch ED-9) generates `gen/android`; it is not committed yet, so
these scripts do not run until it is.

`frontendDist` is `../dist/app`, the same directory the desktop shell uses — one
build of the front end serves every shell, plus the server's `--web-root`.
