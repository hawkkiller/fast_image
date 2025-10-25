import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:image/image.dart';

class DartImageBenchmark extends BenchmarkBase {
  DartImageBenchmark() : super('image');

  late Image image;

  @override
  void setup() {
    super.setup();
    image = decodeImage(File('assets/example_img.jpg').readAsBytesSync())!;
  }

  @override
  void run() {
    resize(image, width: 1920 * 2, height: 1080 * 2, interpolation: Interpolation.cubic);
  }
}
