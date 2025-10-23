import 'package:fast_image/src/bindings/bindings.dart';
import 'package:ffi/ffi.dart';

void main() {
  final helloPtr = hello_from_rust();
  final hello = helloPtr.cast<Utf8>().toDartString();

  print(hello);
}
