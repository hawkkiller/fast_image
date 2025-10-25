import 'dart:convert';
import 'dart:io';

import 'package:benchmarks/dart_image_benchmark.dart';
import 'package:benchmarks/fast_image_benchmark.dart';

void main() {
  print('\n=== Image Processing Benchmarks ===\n');
  print('Format: {benchmark_name}(RunTime): {time} us.\n');

  final results = <String, Map<String, dynamic>>{};

  // Resize benchmarks - various sizes
  print('--- Resize Benchmarks ---');
  final resizeSizes = [
    (800, 600),
    (1920, 1080),
    (3840, 2160), // 4K
  ];

  for (final (width, height) in resizeSizes) {
    final operation = 'resize_${width}x$height';
    results[operation] = {};
    
    final fastImageTime = FastImageResizeBenchmark(width, height).measure();
    print('fast_image.$operation(RunTime): $fastImageTime us.');
    results[operation]!['fast_image_us'] = fastImageTime;
    
    final dartImageTime = DartImageResizeBenchmark(width, height).measure();
    print('dart_image.$operation(RunTime): $dartImageTime us.');
    results[operation]!['dart_image_us'] = dartImageTime;
    print('');
  }

  // Load benchmarks
  print('--- Load Benchmarks ---');
  results['load'] = {};
  
  final fastImageLoadTime = FastImageLoadBenchmark().measure();
  print('fast_image.load(RunTime): $fastImageLoadTime us.');
  results['load']!['fast_image_us'] = fastImageLoadTime;
  
  final dartImageLoadTime = DartImageLoadBenchmark().measure();
  print('dart_image.load(RunTime): $dartImageLoadTime us.');
  results['load']!['dart_image_us'] = dartImageLoadTime;
  print('');

  // Encode benchmarks
  print('--- Encode Benchmarks ---');
  results['encode_jpeg'] = {};
  
  final fastImageEncodeTime = FastImageEncodeBenchmark().measure();
  print('fast_image.encode_jpeg(RunTime): $fastImageEncodeTime us.');
  results['encode_jpeg']!['fast_image_us'] = fastImageEncodeTime;
  
  final dartImageEncodeTime = DartImageEncodeBenchmark().measure();
  print('dart_image.encode_jpeg(RunTime): $dartImageEncodeTime us.');
  results['encode_jpeg']!['dart_image_us'] = dartImageEncodeTime;
  print('');

  // Rotate benchmarks
  print('--- Rotate Benchmarks ---');
  results['rotate_90'] = {};
  
  final fastImageRotateTime = FastImageRotateBenchmark().measure();
  print('fast_image.rotate_90(RunTime): $fastImageRotateTime us.');
  results['rotate_90']!['fast_image_us'] = fastImageRotateTime;
  
  final dartImageRotateTime = DartImageRotateBenchmark().measure();
  print('dart_image.rotate_90(RunTime): $dartImageRotateTime us.');
  results['rotate_90']!['dart_image_us'] = dartImageRotateTime;
  print('');

  // Flip benchmarks
  print('--- Flip Benchmarks ---');
  results['flip_horizontal'] = {};
  
  final fastImageFlipTime = FastImageFlipBenchmark().measure();
  print('fast_image.flip_horizontal(RunTime): $fastImageFlipTime us.');
  results['flip_horizontal']!['fast_image_us'] = fastImageFlipTime;
  
  final dartImageFlipTime = DartImageFlipBenchmark().measure();
  print('dart_image.flip_horizontal(RunTime): $dartImageFlipTime us.');
  results['flip_horizontal']!['dart_image_us'] = dartImageFlipTime;
  print('');

  // Save results to JSON file
  final jsonOutput = {
    'timestamp': DateTime.now().toIso8601String(),
    'results': results,
  };
  
  final file = File('benchmark_results.json');
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(jsonOutput),
  );
  
  print('\n=== Benchmarks Complete ===');
  print('Results saved to: ${file.absolute.path}\n');
}
