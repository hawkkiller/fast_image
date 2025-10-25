import 'package:fast_image/fast_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

Future<Uint8List> upscaleAndSaveImage({
  required ui.Image originalImage,
  required int newWidth,
  required int newHeight,
  ui.FilterQuality quality = ui.FilterQuality.high,
}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
  );

  final Rect src = Rect.fromLTWH(
    0,
    0,
    originalImage.width.toDouble(),
    originalImage.height.toDouble(),
  );
  final Rect dst = Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble());
  final Paint paint = Paint()..filterQuality = quality;

  canvas.drawImageRect(originalImage, src, dst, paint);
  final ui.Picture picture = recorder.endRecording();
  final ui.Image finalImage = picture.toImageSync(newWidth, newHeight);

  return finalImage.toByteData(format: ui.ImageByteFormat.png).then((byteData) {
    return byteData!.buffer.asUint8List();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upscaler',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _timeMessage = '';
  bool _isLoading = false;
  String? _savedPath;

  Future<void> _upscaleImageWithFlutter() async {
    setState(() {
      _isLoading = true;
      _timeMessage = '';
      _savedPath = null;
    });

    final stopwatch = Stopwatch()..start();

    final ByteData data = await rootBundle.load('assets/example_img.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    final int newWidth = originalImage.width * 2;
    final int newHeight = originalImage.height * 2;

    final upscaledBytes = await upscaleAndSaveImage(
      originalImage: originalImage,
      newWidth: newWidth,
      newHeight: newHeight,
    );

    // Save the upscaled image to device
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/upscaled_$timestamp.png';
    final file = File(filePath);
    await file.writeAsBytes(upscaledBytes);

    stopwatch.stop();

    setState(() {
      _isLoading = false;
      _savedPath = filePath;
      _timeMessage = 'Upscaled with Flutter in ${stopwatch.elapsedMilliseconds}ms';
    });
  }

  Future<void> _upscaleImageWithNative() async {
    setState(() {
      _isLoading = true;
      _timeMessage = '';
      _savedPath = null;
    });

    final stopwatch = Stopwatch()..start();

    final ByteData data = await rootBundle.load('assets/example_img.jpg');
    final Uint8List bytes = data.buffer.asUint8List();

    final fastImage = FastImage.fromMemory(bytes);
    final resizedImage = fastImage.resize(1920 * 2, 1080 * 2);

    fastImage.dispose();
    final upscaledBytes = resizedImage.encode(ImageFormatEnum.Png);
    resizedImage.dispose();

    // Save the upscaled image to device
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/upscaled_$timestamp.png';
    final file = File(filePath);
    await file.writeAsBytes(upscaledBytes);

    stopwatch.stop();
    
    setState(() {
      _isLoading = false;
      _timeMessage = 'Upscaled with Rust in ${stopwatch.elapsedMilliseconds}ms';
      _savedPath = filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Image Upscaler'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  ElevatedButton(
                    onPressed: _upscaleImageWithFlutter,
                    child: const Text('Upscale with Flutter'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _upscaleImageWithNative,
                    child: const Text('Upscale with Rust'),
                  ),
                ],
                const SizedBox(height: 20),
                Text(_timeMessage, style: Theme.of(context).textTheme.headlineSmall),
                if (_savedPath != null) ...[
                  const SizedBox(height: 10),
                  SelectableText(
                    'Saved to: $_savedPath',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
