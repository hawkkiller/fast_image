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
  FastImage._(this._handle) : assert(_handle != ffi.nullptr) {
    _finalizer.attach(this, _handle, detach: this);
  }

  static final Finalizer<ffi.Pointer<ImageHandle>> _finalizer =
      Finalizer((handle) => fast_image_free(handle));

  final ffi.Pointer<ImageHandle> _handle;
  bool _isDisposed = false;
  FastImageMetadata? _cachedMetadata;

  /// Whether the native resources have been disposed.
  bool get isDisposed => _isDisposed;

  /// Loads an image from a file path
  ///
  /// Throws [InvalidPathException] if the path is empty or invalid.
  /// Throws [IoException] if the file cannot be read.
  /// Throws [DecodingException] if the image format cannot be decoded.
  /// Throws [UnsupportedFormatException] if the format is not supported.
  factory FastImage.fromFile(String path) {
    if (path.trim().isEmpty) {
      throw InvalidPathException('path is empty');
    }
    final pathPtr = path.toNativeUtf8();
    final errorPtr = malloc.allocate<ffi.Uint32>(ffi.sizeOf<ffi.Uint32>());
    try {
      final handle = fast_image_load_with_error(pathPtr.cast(), errorPtr);
      if (handle == ffi.nullptr) {
        final errorCode = ImageErrorCode.fromValue(errorPtr.value);
        throw FastImageException.fromCode(errorCode, context: 'path: $path');
      }
      return FastImage._(handle);
    } finally {
      malloc.free(pathPtr);
      malloc.free(errorPtr);
    }
  }

  /// Loads an image from a byte buffer
  ///
  /// Throws [DecodingException] if the buffer is empty or cannot be decoded.
  /// Throws [UnsupportedFormatException] if the format is not supported.
  factory FastImage.fromMemory(Uint8List data) {
    if (data.isEmpty) {
      throw DecodingException('input buffer is empty');
    }
    final dataPtr = malloc.allocate<ffi.Uint8>(data.length);
    final errorPtr = malloc.allocate<ffi.Uint32>(ffi.sizeOf<ffi.Uint32>());
    try {
      dataPtr.asTypedList(data.length).setAll(0, data);
      final handle = fast_image_load_from_memory_with_error(dataPtr, data.length, errorPtr);
      if (handle == ffi.nullptr) {
        final errorCode = ImageErrorCode.fromValue(errorPtr.value);
        throw FastImageException.fromCode(errorCode, context: 'input: memory');
      }
      return FastImage._(handle);
    } finally {
      malloc.free(dataPtr);
      malloc.free(errorPtr);
    }
  }

  /// Loads an image from a byte buffer with a specific format
  ///
  /// Throws [DecodingException] if the buffer is empty or cannot be decoded.
  /// Throws [UnsupportedFormatException] if the format is not supported.
  factory FastImage.fromMemoryWithFormat(Uint8List data, ImageFormatEnum format) {
    if (data.isEmpty) {
      throw DecodingException('input buffer is empty');
    }
    final dataPtr = malloc.allocate<ffi.Uint8>(data.length);
    final errorPtr = malloc.allocate<ffi.Uint32>(ffi.sizeOf<ffi.Uint32>());
    try {
      dataPtr.asTypedList(data.length).setAll(0, data);
      final handle = fast_image_load_from_memory_with_format_and_error(
        dataPtr,
        data.length,
        format.value,
        errorPtr,
      );
      if (handle == ffi.nullptr) {
        final errorCode = ImageErrorCode.fromValue(errorPtr.value);
        throw FastImageException.fromCode(errorCode, context: 'input: memory, format: ${format.name}');
      }
      return FastImage._(handle);
    } finally {
      malloc.free(dataPtr);
      malloc.free(errorPtr);
    }
  }

  /// Checks if the image has been disposed
  void _checkDisposed() {
    if (_isDisposed) {
      throw InvalidPointerException('image has been disposed');
    }
  }

  void _validateDimensions(int width, int height, {String? context}) {
    if (width <= 0 || height <= 0) {
      throw InvalidDimensionsException(context ?? 'width and height must be > 0');
    }
  }

  void _validateCrop(int x, int y, int width, int height) {
    if (x < 0 || y < 0) {
      throw InvalidDimensionsException('x and y must be >= 0');
    }
    _validateDimensions(width, height, context: 'crop width and height must be > 0');

    // Bounds validation
    final meta = getMetadata();
    if (x + width > meta.width) {
      throw InvalidDimensionsException(
        'crop right edge (${x + width}) exceeds image width (${meta.width})',
      );
    }
    if (y + height > meta.height) {
      throw InvalidDimensionsException(
        'crop bottom edge (${y + height}) exceeds image height (${meta.height})',
      );
    }
  }

  FastImage _fromNativeHandle(ffi.Pointer<ImageHandle> handle, String operation) {
    if (handle == ffi.nullptr) {
      throw UnknownException('operation: $operation');
    }
    return FastImage._(handle);
  }

  ImageErrorCode _errorFromValue(int value) {
    try {
      return ImageErrorCode.fromValue(value);
    } on ArgumentError {
      return ImageErrorCode.Unknown;
    }
  }

  /// Gets the image metadata (width, height, color type).
  ///
  /// The result is cached; subsequent calls return the cached value
  /// without an FFI round-trip.
  FastImageMetadata getMetadata() {
    _checkDisposed();
    if (_cachedMetadata != null) return _cachedMetadata!;

    final metadataPtr = malloc.allocate<ImageMetadata>(ffi.sizeOf<ImageMetadata>());
    try {
      final errorCode = fast_image_get_metadata(_handle, metadataPtr);
      final error = _errorFromValue(errorCode);
      if (error != ImageErrorCode.Success) {
        throw FastImageException.fromCode(error, context: 'operation: metadata');
      }
      _cachedMetadata = FastImageMetadata.fromNative(metadataPtr);
      return _cachedMetadata!;
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
  /// Throws [InvalidPathException] if the path is empty.
  void saveToFile(String path) {
    _checkDisposed();
    if (path.trim().isEmpty) {
      throw InvalidPathException('path is empty');
    }
    final pathPtr = path.toNativeUtf8();
    try {
      final errorCode = fast_image_save(_handle, pathPtr.cast());
      final error = _errorFromValue(errorCode);
      if (error != ImageErrorCode.Success) {
        throw FastImageException.fromCode(error, context: 'path: $path');
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
      final errorCode = fast_image_write_to(_handle, format.value, outDataPtr, outLenPtr);
      final error = _errorFromValue(errorCode);
      if (error != ImageErrorCode.Success) {
        throw FastImageException.fromCode(error, context: 'format: ${format.name}');
      }

      final dataPtr = outDataPtr.value;
      final len = outLenPtr.value;
      if (dataPtr == ffi.nullptr || len == 0) {
        throw UnknownException('operation: encode');
      }

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
    _validateDimensions(width, height);
    final handle = fast_image_resize(_handle, width, height, filter.value);
    return _fromNativeHandle(handle, 'resize');
  }

  /// Resizes the image to exact dimensions (may distort aspect ratio)
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage resizeExact(int width, int height, {FilterTypeEnum filter = FilterTypeEnum.Lanczos3}) {
    _checkDisposed();
    _validateDimensions(width, height);
    final handle = fast_image_resize_exact(_handle, width, height, filter.value);
    return _fromNativeHandle(handle, 'resizeExact');
  }

  /// Crops the image to the specified rectangle
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage crop(int x, int y, int width, int height) {
    _checkDisposed();
    _validateCrop(x, y, width, height);
    final handle = fast_image_crop_imm(_handle, x, y, width, height);
    return _fromNativeHandle(handle, 'crop');
  }

  /// Rotates the image 90 degrees clockwise
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage rotate90() {
    _checkDisposed();
    final handle = fast_image_rotate90(_handle);
    return _fromNativeHandle(handle, 'rotate90');
  }

  /// Rotates the image 180 degrees
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage rotate180() {
    _checkDisposed();
    final handle = fast_image_rotate180(_handle);
    return _fromNativeHandle(handle, 'rotate180');
  }

  /// Rotates the image 270 degrees clockwise (90 degrees counter-clockwise)
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage rotate270() {
    _checkDisposed();
    final handle = fast_image_rotate270(_handle);
    return _fromNativeHandle(handle, 'rotate270');
  }

  /// Flips the image horizontally
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage flipHorizontal() {
    _checkDisposed();
    final handle = fast_image_fliph(_handle);
    return _fromNativeHandle(handle, 'flipHorizontal');
  }

  /// Flips the image vertically
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage flipVertical() {
    _checkDisposed();
    final handle = fast_image_flipv(_handle);
    return _fromNativeHandle(handle, 'flipVertical');
  }

  /// Applies a Gaussian blur to the image.
  ///
  /// [sigma] controls the blur strength (higher = more blur).
  /// A value of 0 results in no change.
  /// Throws [ArgumentError] if sigma is negative.
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage blur(double sigma) {
    _checkDisposed();
    if (sigma < 0) {
      throw ArgumentError.value(sigma, 'sigma', 'Must be >= 0');
    }
    final handle = fast_image_blur(_handle, sigma);
    return _fromNativeHandle(handle, 'blur');
  }

  /// Adjusts the brightness of the image
  /// 
  /// [value] is added to each pixel's brightness (can be negative)
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage brightness(int value) {
    _checkDisposed();
    final handle = fast_image_brighten(_handle, value);
    return _fromNativeHandle(handle, 'brightness');
  }

  /// Adjusts the contrast of the image
  /// 
  /// [contrast] is the contrast factor (1.0 = no change, >1.0 = more contrast)
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage contrast(double contrast) {
    _checkDisposed();
    final handle = fast_image_adjust_contrast(_handle, contrast);
    return _fromNativeHandle(handle, 'contrast');
  }

  /// Converts the image to grayscale
  /// 
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage grayscale() {
    _checkDisposed();
    final handle = fast_image_grayscale(_handle);
    return _fromNativeHandle(handle, 'grayscale');
  }

  /// Inverts the colors of the image.
  ///
  /// Returns a new [FastImage] instance. The original is not modified.
  FastImage invert() {
    _checkDisposed();
    final handle = fast_image_invert(_handle);
    return _fromNativeHandle(handle, 'invert');
  }

  /// Disposes the native resources
  /// 
  /// Call this when the image is no longer needed to prevent memory leaks.
  /// A finalizer provides a fallback, but explicit disposal is recommended.
  void dispose() {
    if (!_isDisposed) {
      _finalizer.detach(this);
      fast_image_free(_handle);
      _isDisposed = true;
    }
  }
}
