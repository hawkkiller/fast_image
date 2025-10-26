import 'dart:io';
import 'dart:typed_data';

import 'package:fast_image/fast_image.dart';

void main() async {
  final url =
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bW91bnRhaW58ZW58MHx8MHx8fDA%3D&w=1000&q=80';
  final client = await HttpClient();
  final response = await client.getUrl(Uri.parse(url)).then((req) => req.close());
  final bytes = await response
      .expand((element) => element)
      .toList()
      .then((value) => Uint8List.fromList(value));
  client.close();

  final stopwatch = Stopwatch()..start();
  final image = FastImage.fromMemory(bytes);
  final upscaledImage = image.resize(3840, 2160);
  upscaledImage.saveToFile('upscaled_image.jpg');
  print('Image upscaled in ${stopwatch.elapsedMilliseconds}ms');
}
