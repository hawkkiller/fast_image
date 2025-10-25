import 'package:benchmarks/dart_image_benchmark.dart';
import 'package:benchmarks/fast_image_benchmark.dart';

void main() async {
  final fastImageBenchmark = FastImageBenchmark();
  fastImageBenchmark.report();

  final dartImageBenchmark = DartImageBenchmark();
  dartImageBenchmark.report();
}
