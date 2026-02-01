## 0.0.2

- **Breaking:** `invert()` now returns a new `FastImage` instead of mutating in-place.
- **Breaking:** Removed deprecated `resizeToFit()` method (use `resize()` instead).
- Added metadata caching to avoid redundant FFI calls for `width`, `height`, `colorType`.
- Added bounds validation for `crop()` - now throws `InvalidDimensionsException` if crop rectangle exceeds image bounds.
- Improved error handling in load functions - now throws specific exceptions (`IoException`, `DecodingException`, `UnsupportedFormatException`) instead of generic `LoadException`.
- Improved documentation for `blur()` method.

## 0.0.1

- Finalized the Dart API with typed exceptions.
- Added context to exceptions for clearer error messages.
- Added a finalizer and `isDisposed` for safer resource handling.