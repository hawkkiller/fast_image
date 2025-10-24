import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'bindings/bindings.dart';
import 'fast_image_exception.dart';
import 'image_metadata.dart';

/// A fast image processing library
/// 
/// This class provides methods for loading, saving, and manipulating images.
/// Images are backed by native Rust code for high performance.
/// 
/// Example:
/// ```dart
/// final image = FastImage.fromFile('input.jpg');
/// final resized = image.resize(800, 600);
/// resized.saveToFile('output.jpg');
/// resized.dispose();
/// image.dispose();
/// ```
final class FastImage {
  FastImage._(this._handle) : assert(_handle != ffi.nullptr);

  final ffi.Pointer<ImageHandle> _handle;
  bool _isDisposed = false;

  /// Loads an image from a file path
  /// 
  /// Throws [LoadException] if the image cannot be loaded.
  factory FastImage.fromFile(String path) {
    final pathPtr = path.toNativeUtf8();
    try {
      final handle = fast_image_load(pathPtr.cast());
      if (handle == ffi.nullptr) {
        throw LoadException(path);
      }
      return FastImage._(handle);
    } finally {
      malloc.free(pathPtr);
    }
  }

  /// Loads an image from a byte buffer
  /// 
  /// Throws [LoadException] if the image cannot be loaded.
  factory FastImage.fromMemory(Uint8List data) {
    final dataPtr = malloc.allocate<ffi.Uint8>(data.length);
    try {
      dataPtr.asTypedList(data.length).setAll(0, data);
      final handle = fast_image_load_from_memory(dataPtr, data.length);
      if (handle == ffi.nullptr) {
        throw LoadException();
      }
      return FastImage._(handle);
    } finally {
      malloc.free(dataPtr);
    }
  }

  /// Loads an image from a byte buffer with a specific format
  /// 
  /// Throws [LoadException] if the image cannot be loaded.
  factory FastImage.fromMemoryWithFormat(Uint8List data, ImageFormatEnum format) {
    final dataPtr = malloc.allocate<ffi.Uint8>(data.length);
    try {
      dataPtr.asTypedList(data.length).setAll(0, data);
      final handle = fast_image_load_from_memory_with_format(
        dataPtr,
        data.length,
        format.value,
      );
      if (handle == ffi.nullptr) {
        throw LoadException();
      }
      return FastImage._(handle);
    } finally {
      malloc.free(dataPtr);
    }
  }

  /// Checks if the image has been disposed
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('FastImage has been disposed');
    }
  }

  /// Gets the image metadata (width, height, color type)
  FastImageMetadata getMetadata() {
    _checkDisposed();
    final metadataPtr = malloc.allocate<ImageMetadata>(ffi.sizeOf<ImageMetadata>());
    try {
      final errorCode = fast_image_get_metadata(_handle, metadataPtr);
      final error = ImageErrorCode.fromValue(errorCode);
      if (error != ImageErrorCode.Success) {
        throw FastImageException.fromCode(error);
      }
      return FastImageMetadata.fromNative(metadataPtr);
    } finally {
      malloc.free(metadataPtr);
    }
  }

  /// Gets the image width
  int get width => getMetadata().width;

  /// Gets the image height
  int get height => getMetadata().height;

  /// Gets the image color type
  ColorType get colorType => getMetadata().colorType;

  /// Saves the image to a file
  /// 
  /// The format is determined by the file extension.
  void saveToFile(String path) {
    _checkDisposed();
    final pathPtr = path.toNativeUtf8();
    try {
      final errorCode = fast_image_save(_handle, pathPtr.cast());
      final error = ImageErrorCode.fromValue(errorCode);
      if (error != ImageErrorCode.Success) {
        throw FastImageException.fromCode(error);
      }
    } finally {
      malloc.free(pathPtr);
    }
  }

  /// Encodes the image to a byte buffer in the specified format
  Uint8List encode(ImageFormatEnum format) {
    _checkDisposed();
    final outDataPtr = malloc.allocate<ffi.Pointer<ffi.Uint8>>(ffi.sizeOf<ffi.Pointer<ffi.Uint8>>());
    final outLenPtr = malloc.allocate<ffi.UintPtr>(ffi.sizeOf<ffi.UintPtr>());
    
    try {
      final errorCode = fast_image_encode(_handle, format.value, outDataPtr, outLenPtr);
      final error = ImageErrorCode.fromValue(errorCode);
      if (error != ImageErrorCode.Success) {
        throw FastImageException.fromCode(error);
      }

      final dataPtr = outDataPtr.value;
      final len = outLenPtr.value;

      final result = Uint8List.fromList(dataPtr.asTypedList(len));
      
      // Free the buffer allocated by Rust
      fast_image_free_buffer(dataPtr, len);
      
      return result;
    } finally {
      malloc.free(outDataPtr);
      malloc.free(outLenPtr);
    }
  }

  /// Resizes the image to the specified dimensions, maintaining aspect ratio
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage resize(int width, int height, {FilterTypeEnum filter = FilterTypeEnum.Lanczos3}) {
    _checkDisposed();
    final handle = fast_image_resize(_handle, width, height, filter.value);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Resizes the image to exact dimensions (may distort aspect ratio)
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage resizeExact(int width, int height, {FilterTypeEnum filter = FilterTypeEnum.Lanczos3}) {
    _checkDisposed();
    final handle = fast_image_resize_exact(_handle, width, height, filter.value);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Resizes the image to fit within the specified dimensions
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage resizeToFit(int width, int height, {FilterTypeEnum filter = FilterTypeEnum.Lanczos3}) {
    _checkDisposed();
    final handle = fast_image_resize_to_fit(_handle, width, height, filter.value);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Crops the image to the specified rectangle
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage crop(int x, int y, int width, int height) {
    _checkDisposed();
    final handle = fast_image_crop(_handle, x, y, width, height);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Rotates the image 90 degrees clockwise
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage rotate90() {
    _checkDisposed();
    final handle = fast_image_rotate_90(_handle);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Rotates the image 180 degrees
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage rotate180() {
    _checkDisposed();
    final handle = fast_image_rotate_180(_handle);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Rotates the image 270 degrees clockwise (90 degrees counter-clockwise)
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage rotate270() {
    _checkDisposed();
    final handle = fast_image_rotate_270(_handle);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Flips the image horizontally
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage flipHorizontal() {
    _checkDisposed();
    final handle = fast_image_flip_horizontal(_handle);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Flips the image vertically
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage flipVertical() {
    _checkDisposed();
    final handle = fast_image_flip_vertical(_handle);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Applies a Gaussian blur to the image
  /// 
  /// [sigma] controls the blur strength (higher = more blur)
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage blur(double sigma) {
    _checkDisposed();
    final handle = fast_image_blur(_handle, sigma);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Adjusts the brightness of the image
  /// 
  /// [value] is added to each pixel's brightness (can be negative)
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage brightness(int value) {
    _checkDisposed();
    final handle = fast_image_brightness(_handle, value);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Adjusts the contrast of the image
  /// 
  /// [contrast] is the contrast factor (1.0 = no change, >1.0 = more contrast)
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage contrast(double contrast) {
    _checkDisposed();
    final handle = fast_image_contrast(_handle, contrast);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Converts the image to grayscale
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage grayscale() {
    _checkDisposed();
    final handle = fast_image_grayscale(_handle);
    if (handle == ffi.nullptr) {
      throw LoadException();
    }
    return FastImage._(handle);
  }

  /// Inverts the colors of the image (in-place operation)
  /// 
  /// This mutates the current image unlike other operations.
  void invert() {
    _checkDisposed();
    final errorCode = fast_image_invert(_handle);
    final error = ImageErrorCode.fromValue(errorCode);
    if (error != ImageErrorCode.Success) {
      throw FastImageException.fromCode(error);
    }
  }

  /// Disposes the native resources
  /// 
  /// Must be called when the image is no longer needed to prevent memory leaks.
  void dispose() {
    if (!_isDisposed) {
      fast_image_free(_handle);
      _isDisposed = true;
    }
  }
}
