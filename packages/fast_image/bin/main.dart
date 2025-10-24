import 'package:fast_image/fast_image.dart';

void main() {
  final image = FastImage.fromFile('assets/img/example_img.jpg');
  final upscaledImage = image.resize(3840, 2160);

  upscaledImage.saveToFile('upscaled_image.jpg');
}
