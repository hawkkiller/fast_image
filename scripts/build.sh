#!/bin/bash
set -e

# The root directory of the Dart package where libs will be stored.
DEST_DIR="./packages/fast_image/assets/libs"

# --- Build for macOS (Apple Silicon) ---
echo "Building for macOS aarch64..."
(cd native && cargo build --release --target aarch64-apple-darwin)
cp "./native/target/aarch64-apple-darwin/release/libnative.dylib" "$DEST_DIR/libmacos-arm64.dylib"

# --- Build for macOS (Intel) ---
echo "Building for macOS x86_64..."
(cd native && cargo build --release --target x86_64-apple-darwin)
cp "./native/target/x86_64-apple-darwin/release/libnative.dylib" "$DEST_DIR/libmacos-x86_64.dylib"
