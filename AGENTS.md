# Pixer

Cross-platform image manipulation library: Dart API backed by Rust via FFI.

## Project Structure

- `/native` - Rust crate (pixer) with image processing logic
- `/packages/pixer` - Main Dart package with FFI bindings
- `/packages/benchmarks` - Performance benchmarks
- `/packages/upscale_flutter` - Flutter demo app

## Commands

```bash
# Build native library locally
dart tool/build.dart -o<os> -a<arch>
# Examples: -omacos -aarm64, -olinux -ax64, -oandroid -aarm64

# Generate FFI bindings (after changing native/src/ffi.rs)
dart run ffigen --config ffigen.yaml
```

## Release

1. Push changes via PR to `main`
2. Tag and push: `git tag pixer-assets-v1.0.0 && git push origin pixer-assets-v1.0.0`
3. CI builds all platforms and creates GitHub Release

## Architecture

- Rust code in `native/src/`: `lib.rs` (entry), `api.rs` (image ops), `ffi.rs` (C bindings)
- Dart bindings generated via ffigen into `lib/src/bindings/`
- Native assets delivered via Dart build hooks (see `hook/` directory)
