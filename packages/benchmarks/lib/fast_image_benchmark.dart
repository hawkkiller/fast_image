import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:fast_image/fast_image.dart';

class FastImageBenchmark extends BenchmarkBase {
  FastImageBenchmark() : super('fast_image');

  late FastImage image;

  @override
  void setup() {
    super.setup();
    image = FastImage.fromFile('assets/example_img.jpg');
  }

  @override
  void teardown() {
    super.teardown();
    image.dispose();
  }

  @override
  void run() {
    image.resize(1920 * 2, 1080 * 2);
  }
}
