# Fast Image

Fast, cross-platform image manipulation for Dart, backed by Rust via FFI.
Native binaries are delivered on demand using Dart build hooks.

## Usage

```dart
import 'package:fast_image/fast_image.dart';

final image = FastImage.fromFile('input.jpg');
final resized = image.resize(800, 600);
resized.saveToFile('output.png');
resized.dispose();
image.dispose();
```

## Exceptions

All failures throw typed `FastImageException` subclasses (for example,
`InvalidPathException`, `DecodingException`, `EncodingException`).

## Resource management

Call `dispose()` when you are done with an image to release native resources.
A finalizer acts as a fallback, but explicit disposal is recommended.

## Release Process

When you modify Dart or Rust code and want to release new native assets:

1. Push changes to a branch and open a PR to `main` — CI builds and tests all platforms
2. Merge the PR to `main`
3. Create and push a tag: `git tag fast_image-assets-v1.0.0 && git push origin fast_image-assets-v1.0.0`
4. GitHub Actions builds libraries for all platforms (Linux, macOS, Windows, Android, iOS)
5. A GitHub Release is created automatically with all native binaries attached