import 'bindings/bindings.dart';

/// Base exception for fast_image errors
sealed class FastImageException implements Exception {
  const FastImageException(this.message, this.code);

  final String message;
  final ImageErrorCode code;

  @override
  String toString() => 'FastImageException: $message (code: ${code.name})';

  /// Creates an exception from an error code
  factory FastImageException.fromCode(ImageErrorCode code) {
    return switch (code) {
      ImageErrorCode.Success => throw StateError('Cannot create exception from success code'),
      ImageErrorCode.InvalidPath => InvalidPathException(),
      ImageErrorCode.UnsupportedFormat => UnsupportedFormatException(),
      ImageErrorCode.DecodingError => DecodingException(),
      ImageErrorCode.EncodingError => EncodingException(),
      ImageErrorCode.IoError => IoException(),
      ImageErrorCode.InvalidDimensions => InvalidDimensionsException(),
      ImageErrorCode.InvalidPointer => InvalidPointerException(),
      ImageErrorCode.Unknown => UnknownException(),
    };
  }
}

/// Exception thrown when the path is invalid
final class InvalidPathException extends FastImageException {
  InvalidPathException() : super('Invalid path provided', ImageErrorCode.InvalidPath);
}

/// Exception thrown when the format is not supported
final class UnsupportedFormatException extends FastImageException {
  UnsupportedFormatException() : super('Unsupported image format', ImageErrorCode.UnsupportedFormat);
}

/// Exception thrown when decoding fails
final class DecodingException extends FastImageException {
  DecodingException() : super('Failed to decode image', ImageErrorCode.DecodingError);
}

/// Exception thrown when encoding fails
final class EncodingException extends FastImageException {
  EncodingException() : super('Failed to encode image', ImageErrorCode.EncodingError);
}

/// Exception thrown when I/O operation fails
final class IoException extends FastImageException {
  IoException() : super('I/O error occurred', ImageErrorCode.IoError);
}

/// Exception thrown when dimensions are invalid
final class InvalidDimensionsException extends FastImageException {
  InvalidDimensionsException() : super('Invalid dimensions', ImageErrorCode.InvalidDimensions);
}

/// Exception thrown when a null pointer is encountered
final class InvalidPointerException extends FastImageException {
  InvalidPointerException() : super('Invalid pointer (image may have been disposed)', ImageErrorCode.InvalidPointer);
}

/// Exception thrown for unknown errors
final class UnknownException extends FastImageException {
  UnknownException() : super('An unknown error occurred', ImageErrorCode.Unknown);
}

/// Exception thrown when loading an image fails
final class LoadException extends FastImageException {
  LoadException([String? path]) 
      : super(
          path != null ? 'Failed to load image from: $path' : 'Failed to load image',
          ImageErrorCode.DecodingError,
        );
}
