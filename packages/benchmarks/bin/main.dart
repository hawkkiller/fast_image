import 'package:benchmarks/dart_image_benchmark.dart';
import 'package:benchmarks/fast_image_benchmark.dart';

void main() {
  print('\n=== Image Processing Benchmarks ===\n');
  print('Format: {benchmark_name}(RunTime): {time} us.\n');

  // Resize benchmarks - various sizes
  print('--- Resize Benchmarks ---');
  final resizeSizes = [
    (800, 600),
    (1920, 1080),
    (3840, 2160), // 4K
  ];

  for (final (width, height) in resizeSizes) {
    FastImageResizeBenchmark(width, height).report();
    DartImageResizeBenchmark(width, height).report();
  }

  // Load benchmarks
  print('--- Load Benchmarks ---');
  FastImageLoadBenchmark().report();
  DartImageLoadBenchmark().report();
  print('');

  // Encode benchmarks
  print('--- Encode Benchmarks ---');
  FastImageEncodeBenchmark().report();
  DartImageEncodeBenchmark().report();
  print('');

  // Rotate benchmarks
  print('--- Rotate Benchmarks ---');
  FastImageRotateBenchmark().report();
  DartImageRotateBenchmark().report();
  print('');

  // Flip benchmarks
  print('--- Flip Benchmarks ---');
  FastImageFlipBenchmark().report();
  DartImageFlipBenchmark().report();
  print('');

  print('\n=== Benchmarks Complete ===\n');
}
