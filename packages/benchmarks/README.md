# Benchmarks

Comprehensive benchmarks comparing `fast_image` (Rust-backed) with the pure Dart `image` package.

## Running Benchmarks

```bash
dart run bin/main.dart
```

## Benchmark Categories

### 1. Resize Benchmarks
Tests image resizing at different resolutions:
- 800x600 (SD)
- 1920x1080 (Full HD)
- 3840x2160 (4K)

### 2. Load Benchmarks
Measures image decoding performance from file bytes.

### 3. Encode Benchmarks
Tests JPEG encoding performance.

### 4. Rotate Benchmarks
Measures 90-degree rotation performance.

### 5. Flip Benchmarks
Tests horizontal flip performance.

## Improvements Made

1. **Proper Resource Management**: All `FastImage` instances are properly disposed to prevent memory leaks
2. **Multiple Test Scenarios**: Various image sizes and operations for comprehensive comparison
3. **Fair Comparisons**: Both libraries use comparable quality settings (cubic interpolation)
4. **Better Organization**: Separate benchmark classes for each operation type
5. **Clear Output**: Organized output with categories and formatting

## Expected Results

`fast_image` should demonstrate significant performance advantages, especially for:
- Large image resizing (4K)
- Encoding operations
- Batch transformations

The Rust-backed implementation typically shows 5-50x performance improvements depending on the operation.
