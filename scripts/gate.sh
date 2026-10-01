#!/usr/bin/env sh
# Local quality gate -- run before every commit:  scripts/gate.sh
#
# THIS FILE IS THE ONE LIST OF WHAT "GREEN" MEANS.
# CI runs it verbatim (`.github/workflows/ci.yml` -> `sh scripts/gate.sh`), so a
# check can never drift apart between CI and a developer machine again. If a check
# belongs in CI, it belongs here -- not in the workflow.
#
# This is the management program's own gate (v1.0 M8-4b). It checks **this**
# repository: the Tauri shell crate (`host-tauri`), the desktop crate
# (`src-tauri/`, built standalone), the front end and its regression probes. The
# kernel is checked by the kernel's own gate; the control plane by `riscdom-server`'s.
#
# Requirements: Rust (rustfmt + clippy) and Node >= 22.6 (the UI probes import the
# `.ts` modules and rely on type stripping: default from Node 23.6, needs
# `--experimental-strip-types` on 22.6-23.5). On Linux the two Tauri crates need the
# webkit2gtk / gtk / librsvg / libsoup development packages, and `host-tauri` reaches
# `host-core` (a git dependency pinned to the kernel's `v1.0.0`), which needs
# `libdbus-1-dev` through `keyring`; CI installs them (`.github/workflows/ci.yml`).
#
# Four of the seventeen probes read kernel sources that are **not** in this
# repository (the split moved them out). Each prints a SKIP with its reason instead
# of failing; the cross-repository checks return with M8-4d.
#
# Each step fails fast with a non-zero exit code.
set -eu

cd "$(dirname "$0")/.."

fail() {
  echo "gate: FAILED at $1"
  exit 1
}

echo "==> cargo fmt --all -- --check"
cargo fmt --all -- --check || fail "cargo fmt"

echo "==> cargo clippy (host-tauri)"
cargo clippy --all-targets --no-deps -- -D warnings || fail "cargo clippy"

echo "==> cargo test (host-tauri)"
cargo test --no-fail-fast || fail "cargo test"

echo "==> cargo clippy (src-tauri)"
cargo clippy --manifest-path src-tauri/Cargo.toml --all-targets -- -D warnings || fail "cargo clippy src-tauri"

echo "==> cargo check (src-tauri)"
cargo check --manifest-path src-tauri/Cargo.toml || fail "cargo check src-tauri"

echo "==> npm run build (front end)"
npm run build || fail "npm run build"

echo "==> ui probes (scroll / layout / runs / snapshot / dialog / preflight / theme / i18n / api / login / sse / read-only / node page / network tab / LAN / remote node / executor picker)"
node scripts/probe-ui-scroll.mjs || fail "ui probe (chat scroll)"
node scripts/probe-ui-width.mjs || fail "ui probe (pane layout)"
node scripts/probe-ui-runs.mjs || fail "ui probe (run list)"
node scripts/probe-ui-snapshot.mjs || fail "ui probe (snapshot naming)"
node scripts/probe-ui-dialog.mjs || fail "ui probe (file picker)"
node scripts/probe-ui-preflight.mjs || fail "ui probe (preflight)"
node scripts/probe-ui-theme.mjs || fail "ui probe (theme)"
node scripts/probe-ui-i18n.mjs || fail "ui probe (i18n)"
node scripts/probe-ui-api.mjs || fail "ui probe (api adapter)"
node scripts/probe-ui-login.mjs || fail "ui probe (login gate)"
node scripts/probe-ui-sse.mjs || fail "ui probe (event stream)"
node scripts/probe-ui-web-readonly.mjs || fail "ui probe (read-only board)"
node scripts/probe-ui-node-panel.mjs || fail "ui probe (node page)"
node scripts/probe-ui-network-tab.mjs || fail "ui probe (network tab)"
node scripts/probe-ui-lan.mjs || fail "ui probe (LAN board)"
node scripts/probe-ui-remote.mjs || fail "ui probe (remote node)"
node scripts/probe-ui-executor-selector.mjs || fail "ui probe (executor picker)"

echo "==> ui string registry"
node scripts/check-ui-strings.mjs || fail "ui string registry"

echo "==> wix version guard"
node scripts/check-wix-version.mjs || fail "wix version guard"

echo "gate: OK"
