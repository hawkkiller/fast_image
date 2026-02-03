# Pixer

Fast, cross-platform image manipulation for Dart, powered by Rust via FFI.

## Installation

```yaml
dependencies:
  pixer: ^0.0.2
```

Native binaries are downloaded automatically via Dart build hooks.

## Quick Start

```dart
import 'package:pixer/pixer.dart';

final image = Pixer.fromFile('input.jpg');
final result = image.resize(800, 600);
result.saveToFile('output.png');
result.dispose();
image.dispose();
```

## Loading Images

```dart
// From file (format auto-detected)
final image = Pixer.fromFile('photo.jpg');

// From memory
final bytes = await File('photo.png').readAsBytes();
final image = Pixer.fromMemory(bytes);

// From memory with explicit format
final image = Pixer.fromMemoryWithFormat(bytes, ImageFormatEnum.Png);
```

## Supported Formats

PNG, JPEG, GIF, WebP, BMP, ICO, TIFF

## Image Operations

All operations return a **new** `Pixer` instance; the original is unchanged.

```dart
// Resize (maintains aspect ratio)
final resized = image.resize(800, 600);

// Resize exact (may distort)
final stretched = image.resizeExact(800, 600);

// Crop (x, y, width, height)
final cropped = image.crop(100, 100, 400, 300);

// Rotate
final r90 = image.rotate90();
final r180 = image.rotate180();
final r270 = image.rotate270();

// Flip
final hFlip = image.flipHorizontal();
final vFlip = image.flipVertical();

// Adjustments
final blurred = image.blur(2.5);           // Gaussian blur (sigma)
final bright = image.brightness(30);       // Add to brightness (-255 to 255)
final contrast = image.contrast(1.2);      // Contrast factor (1.0 = unchanged)
final gray = image.grayscale();
final inverted = image.invert();
```

### Resize Filters

```dart
image.resize(800, 600, filter: FilterTypeEnum.Lanczos3);  // Default, high quality
image.resize(800, 600, filter: FilterTypeEnum.Nearest);   // Fastest, pixelated
image.resize(800, 600, filter: FilterTypeEnum.Triangle);  // Bilinear
image.resize(800, 600, filter: FilterTypeEnum.CatmullRom);
image.resize(800, 600, filter: FilterTypeEnum.Gaussian);
```

## Saving & Encoding

```dart
// Save to file (format from extension)
image.saveToFile('output.webp');

// Encode to bytes
final pngBytes = image.encode(ImageFormatEnum.Png);
final jpegBytes = image.encode(ImageFormatEnum.Jpeg);
```

## Metadata

```dart
final meta = image.getMetadata();
print('${meta.width}x${meta.height}, ${meta.colorType}');

// Or directly:
print('${image.width}x${image.height}');
```

## Resource Management

Call `dispose()` when done to free native memory. A finalizer provides a safety net, but explicit disposal is recommended.

```dart
final image = Pixer.fromFile('input.jpg');
try {
  // use image...
} finally {
  image.dispose();
}
```

## Error Handling

All errors throw typed `PixerException` subclasses:

| Exception | Cause |
|-----------|-------|
| `InvalidPathException` | Empty or invalid file path |
| `IoException` | File read/write failure |
| `DecodingException` | Cannot decode image data |
| `EncodingException` | Cannot encode to format |
| `UnsupportedFormatException` | Format not supported |
| `InvalidDimensionsException` | Invalid width/height/crop bounds |
| `InvalidPointerException` | Image already disposed |

## Platforms

Linux, macOS, Windows, Android, iOS