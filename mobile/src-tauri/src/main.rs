// Prevents an extra console window on Windows in release builds — the same line the
// desktop shell carries.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    riscdom_mobile_lib::run()
}
