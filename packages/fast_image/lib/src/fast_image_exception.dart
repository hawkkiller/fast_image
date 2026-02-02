import 'bindings/bindings.dart';

String _withContext(String message, String? context) {
  if (context == null || context.isEmpty) {
    return message;
  }
  return '$message ($context)';
}

/// Base exception for fast_image errors
sealed class FastImageException implements Exception {
  const FastImageException(this.message, this.code);

  final String message;
  final ImageErrorCode code;

  @override
  String toString() => 'FastImageException: $message (code: ${code.name})';

  /// Creates an exception from an error code
  factory FastImageException.fromCode(ImageErrorCode code, {String? context}) {
    return switch (code) {
      ImageErrorCode.Success => throw StateError('Cannot create exception from success code'),
      ImageErrorCode.InvalidPath => InvalidPathException(context),
      ImageErrorCode.UnsupportedFormat => UnsupportedFormatException(context),
      ImageErrorCode.DecodingError => DecodingException(context),
      ImageErrorCode.EncodingError => EncodingException(context),
      ImageErrorCode.IoError => IoException(context),
      ImageErrorCode.InvalidDimensions => InvalidDimensionsException(context),
      ImageErrorCode.InvalidPointer => InvalidPointerException(context),
      ImageErrorCode.Unknown => UnknownException(context),
    };
  }
}

/// Exception thrown when the path is invalid
final class InvalidPathException extends FastImageException {
  InvalidPathException([String? context])
      : super(_withContext('Invalid path provided', context), ImageErrorCode.InvalidPath);
}

/// Exception thrown when the format is not supported
final class UnsupportedFormatException extends FastImageException {
  UnsupportedFormatException([String? context])
      : super(_withContext('Unsupported image format', context), ImageErrorCode.UnsupportedFormat);
}

/// Exception thrown when decoding fails
final class DecodingException extends FastImageException {
  DecodingException([String? context])
      : super(_withContext('Failed to decode image', context), ImageErrorCode.DecodingError);
}

/// Exception thrown when encoding fails
final class EncodingException extends FastImageException {
  EncodingException([String? context])
      : super(_withContext('Failed to encode image', context), ImageErrorCode.EncodingError);
}

/// Exception thrown when I/O operation fails
final class IoException extends FastImageException {
  IoException([String? context])
      : super(_withContext('I/O error occurred', context), ImageErrorCode.IoError);
}

/// Exception thrown when dimensions are invalid
final class InvalidDimensionsException extends FastImageException {
  InvalidDimensionsException([String? context])
      : super(_withContext('Invalid dimensions', context), ImageErrorCode.InvalidDimensions);
}

/// Exception thrown when a null pointer is encountered
final class InvalidPointerException extends FastImageException {
  InvalidPointerException([String? context])
      : super(
          _withContext('Invalid pointer (image may have been disposed)', context),
          ImageErrorCode.InvalidPointer,
        );
}

/// Exception thrown for unknown errors
final class UnknownException extends FastImageException {
  UnknownException([String? context])
      : super(_withContext('An unknown error occurred', context), ImageErrorCode.Unknown);
}

/// Exception thrown when loading an image fails
final class LoadException extends FastImageException {
  LoadException([String? context])
      : super(
          context != null ? _withContext('Failed to load image', context) : 'Failed to load image',
          ImageErrorCode.Unknown,
        );
}
