//! The RiscDom mobile shell (v1.x batch ED-8).
//!
//! A **webview around the web build**: `build.frontendDist` points at the very
//! `dist/app` the desktop shell and a browser load, so the whole React application
//! (`src/`, 42 files) is reused as it is. The shell carries **no commands**, and it
//! links neither the kernel nor the control plane — a phone talks to a
//! `riscdom-server` over HTTP, and the web build's `api/http.ts` is that transport.
//!
//! `main.rs` calls [`run`]. On Android the entry point is reached through the
//! generated `gen/android` project (`tauri android init`, batch ED-9), which is why
//! the function lives on the library side and carries the mobile entry attribute.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

/// Start the mobile shell.
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .run(tauri::generate_context!())
        .expect("error while running the RiscDom mobile shell");
}
