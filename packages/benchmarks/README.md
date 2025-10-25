# Benchmarks

Comprehensive benchmarks comparing `fast_image` (Rust-backed) with the pure Dart `image` package.

## Running Benchmarks

```bash
dart run bin/main.dart
```

## Benchmark Results

_Last updated: October 25, 2025_

| Operation            | fast_image (μs) | image (μs) | Speedup   |
| -------------------- | --------------- | ---------- | --------- |
| **Resize 800x600**   | 146,030         | 3,180,235  | **21.8x** |
| **Resize 1920x1080** | 2,302           | 4,791      | **2.1x**  |
| **Resize 3840x2160** | 913,056         | 56,474,861 | **61.9x** |
| **Load**             | 60,738          | 670,670    | **11.0x** |
| **Encode JPEG**      | 137,764         | 1,140,747  | **8.3x**  |
| **Rotate 90°**       | 16,207          | 312,003    | **19.3x** |
| **Flip Horizontal**  | 15,747          | 374,257    | **23.8x** |

Note: Image given as input for all operations is a Full HD (1920x1080) JPEG image.

### Key Findings

- **Massive 4K Performance**: `fast_image` is **61.9x faster** at resizing 4K images
- **Consistent Advantages**: Speedups range from 2.1x to 61.9x across all operations
- **Memory Efficient**: Rust-backed implementation with proper resource management
- **Production Ready**: Significant performance gains for real-world image processing tasks

## Expected Results

`fast_image` should demonstrate significant performance advantages, especially for:

- Large image resizing (4K)
- Encoding operations
- Batch transformations

The Rust-backed implementation typically shows 5-50x performance improvements depending on the operation.
