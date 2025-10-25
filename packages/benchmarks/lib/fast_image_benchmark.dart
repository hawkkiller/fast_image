import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:fast_image/fast_image.dart';

/// Benchmark for resizing images using the fast_image package
class FastImageResizeBenchmark extends BenchmarkBase {
  FastImageResizeBenchmark(this.targetWidth, this.targetHeight)
      : super('fast_image.resize_${targetWidth}x$targetHeight');

  final int targetWidth;
  final int targetHeight;
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
    // resize returns a new image, we need to dispose it to avoid memory leaks
    final resized = image.resize(targetWidth, targetHeight);
    resized.dispose();
  }
}

/// Benchmark for loading images using the fast_image package
class FastImageLoadBenchmark extends BenchmarkBase {
  FastImageLoadBenchmark() : super('fast_image.load');

  @override
  void run() {
    final image = FastImage.fromFile('assets/example_img.jpg');
    image.dispose();
  }
}

/// Benchmark for encoding images using the fast_image package
class FastImageEncodeBenchmark extends BenchmarkBase {
  FastImageEncodeBenchmark() : super('fast_image.encode_jpeg');

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
    image.encode(ImageFormatEnum.Jpeg);
  }
}

/// Benchmark for rotating images using the fast_image package
class FastImageRotateBenchmark extends BenchmarkBase {
  FastImageRotateBenchmark() : super('fast_image.rotate_90');

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
    final rotated = image.rotate90();
    rotated.dispose();
  }
}

/// Benchmark for flipping images using the fast_image package
class FastImageFlipBenchmark extends BenchmarkBase {
  FastImageFlipBenchmark() : super('fast_image.flip_horizontal');

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
    final flipped = image.flipHorizontal();
    flipped.dispose();
  }
}
