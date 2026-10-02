[中文](README.zh-CN.md) | English

# `mobile/src-tauri` — the RiscDom mobile shell

A small Tauri 2 crate that puts the **web build** (`../../dist/app`) into a webview, so a
phone runs the same React application the desktop shell and a browser do. It is the
Android home of the project (batches ED-8/ED-9a); iOS is a later batch.

**It links neither the kernel nor the control plane.** Its whole dependency list is
`tauri`, `serde` and `serde_json` — no `host-tauri`, no `host-core`, no `net`, no
`server`. A phone reaches a `riscdom-server` over HTTP, and the web build's
`api/http.ts` is that transport. The desktop shell (`../../src-tauri`) does carry those
edges, because there the node is in the same process, and a phone has no node.

| | `../../src-tauri` (desktop) | `mobile/src-tauri` (this) |
|---|---|---|
| Transport | Tauri IPC to an embedded host, or HTTP in `remote` mode | HTTP only |
| Kernel / control plane | `host-tauri` + `server` | neither |
| Writes | yes (it is the node) | no — the browser face is read-only |

## Why a nested project

Tauri's CLI finds the project by looking for `src-tauri/tauri.conf.json` from the working
directory upward, and `--config` only **merges configuration values** — it does not choose
the crate. Pointing the CLI at this crate with `--config` therefore built the *desktop*
shell instead (batch ED-9a's first attempt failed exactly that way, on `host-core`'s
`keyring`). So this crate lives where the CLI expects it: run the CLI **from this
directory**.

## Building

The build needs the Android toolchain (JDK 17+, Android SDK and NDK), which **this
machine does not have** — see `../../README.md` § Mobile. Once it does:

```bash
npm install                                    # at the repository root
npm run tauri:android:build                    # from the repository root
# -> mobile/src-tauri/gen/android/app/build/outputs/apk/**/*.apk
```

`tauri android init` (batch ED-9a) generates `gen/android`; it is committed, so the build
does not need to initialize anything.

`frontendDist` is `../../dist/app`, the same directory the desktop shell uses — one build
of the front end serves every shell, plus the server's `--web-root`.
