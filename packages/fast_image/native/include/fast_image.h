#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Filter type for resizing operations
 */
enum FilterTypeEnum {
  Nearest = 0,
  Triangle = 1,
  CatmullRom = 2,
  Gaussian = 3,
  Lanczos3 = 4,
};
typedef uint32_t FilterTypeEnum;

/**
 * Error codes for image operations
 */
enum ImageErrorCode {
  Success = 0,
  InvalidPath = 1,
  UnsupportedFormat = 2,
  DecodingError = 3,
  EncodingError = 4,
  IoError = 5,
  InvalidDimensions = 6,
  InvalidPointer = 7,
  Unknown = 99,
};
typedef uint32_t ImageErrorCode;

/**
 * Image format enum for encoding/decoding
 */
enum ImageFormatEnum {
  Png = 0,
  Jpeg = 1,
  Gif = 2,
  WebP = 3,
  Bmp = 4,
  Ico = 5,
  Tiff = 6,
};
typedef uint32_t ImageFormatEnum;

/**
 * Opaque handle to an image
 */
typedef struct ImageHandle {
  uint8_t _private[0];
} ImageHandle;

/**
 * Image metadata structure
 */
typedef struct ImageMetadata {
  uint32_t width;
  uint32_t height;
  uint8_t color_type;
} ImageMetadata;

/**
 * Free a string allocated by Rust
 */
void fast_image_free_string(char *ptr);

/**
 * Free image data buffer
 */
void fast_image_free_buffer(uint8_t *ptr, uintptr_t len);

/**
 * Free an image handle
 */
void fast_image_free(struct ImageHandle *handle);

/**
 * Load an image from a file path
 * Returns null on error
 */
struct ImageHandle *fast_image_load(const char *path);

/**
 * Load an image from memory buffer
 */
struct ImageHandle *fast_image_load_from_memory(const uint8_t *data, uintptr_t len);

/**
 * Load an image from memory with specific format
 */
struct ImageHandle *fast_image_load_from_memory_with_format(const uint8_t *data,
                                                            uintptr_t len,
                                                            ImageFormatEnum format);

/**
 * Save an image to a file path
 */
ImageErrorCode fast_image_save(const struct ImageHandle *handle, const char *path);

/**
 * Encode an image to a buffer in the specified format
 * Caller must free the buffer using fast_image_free_buffer
 */
ImageErrorCode fast_image_encode(const struct ImageHandle *handle,
                                 ImageFormatEnum format,
                                 uint8_t **out_data,
                                 uintptr_t *out_len);

/**
 * Get image metadata
 */
ImageErrorCode fast_image_get_metadata(const struct ImageHandle *handle,
                                       struct ImageMetadata *out_metadata);

/**
 * Resize an image
 */
struct ImageHandle *fast_image_resize(const struct ImageHandle *handle,
                                      uint32_t width,
                                      uint32_t height,
                                      FilterTypeEnum filter);

/**
 * Resize an image to exact dimensions
 */
struct ImageHandle *fast_image_resize_exact(const struct ImageHandle *handle,
                                            uint32_t width,
                                            uint32_t height,
                                            FilterTypeEnum filter);

/**
 * Resize to fit within dimensions
 */
struct ImageHandle *fast_image_resize_to_fit(const struct ImageHandle *handle,
                                             uint32_t width,
                                             uint32_t height,
                                             FilterTypeEnum filter);

/**
 * Crop an image
 */
struct ImageHandle *fast_image_crop(const struct ImageHandle *handle,
                                    uint32_t x,
                                    uint32_t y,
                                    uint32_t width,
                                    uint32_t height);

/**
 * Rotate an image 90 degrees clockwise
 */
struct ImageHandle *fast_image_rotate_90(const struct ImageHandle *handle);

/**
 * Rotate an image 180 degrees
 */
struct ImageHandle *fast_image_rotate_180(const struct ImageHandle *handle);

/**
 * Rotate an image 270 degrees clockwise
 */
struct ImageHandle *fast_image_rotate_270(const struct ImageHandle *handle);

/**
 * Flip an image horizontally
 */
struct ImageHandle *fast_image_flip_horizontal(const struct ImageHandle *handle);

/**
 * Flip an image vertically
 */
struct ImageHandle *fast_image_flip_vertical(const struct ImageHandle *handle);

/**
 * Blur an image
 */
struct ImageHandle *fast_image_blur(const struct ImageHandle *handle, float sigma);

/**
 * Adjust brightness
 */
struct ImageHandle *fast_image_brightness(const struct ImageHandle *handle, int32_t value);

/**
 * Adjust contrast
 */
struct ImageHandle *fast_image_contrast(const struct ImageHandle *handle, float c);

/**
 * Convert to grayscale
 */
struct ImageHandle *fast_image_grayscale(const struct ImageHandle *handle);

/**
 * Invert colors (mutates the image)
 */
ImageErrorCode fast_image_invert(struct ImageHandle *handle);
