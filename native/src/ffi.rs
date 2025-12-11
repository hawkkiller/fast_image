use crate::api::*;
use image::DynamicImage;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::slice;

// ============================================================================
// Memory Management
// ============================================================================

/// Free a string allocated by Rust
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

/// Free image data buffer
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_free_buffer(ptr: *mut u8, len: usize) {
    if !ptr.is_null() && len > 0 {
        unsafe {
            let _ = Vec::from_raw_parts(ptr, len, len);
        }
    }
}

/// Free an image handle
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_free(handle: *mut ImageHandle) {
    if !handle.is_null() {
        unsafe {
            let _ = Box::from_raw(handle as *mut DynamicImage);
        }
    }
}

// ============================================================================
// Image Loading
// ============================================================================

/// Load an image from a file path
/// Returns null on error
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_load(path: *const c_char) -> *mut ImageHandle {
    if path.is_null() {
        return std::ptr::null_mut();
    }

    let path_str = unsafe {
        match CStr::from_ptr(path).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        }
    };

    match load_image(path_str) {
        Ok(img) => Box::into_raw(Box::new(img)) as *mut ImageHandle,
        Err(_) => std::ptr::null_mut(),
    }
}

/// Load an image from memory buffer
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_load_from_memory(
    data: *const u8,
    len: usize,
) -> *mut ImageHandle {
    if data.is_null() || len == 0 {
        return std::ptr::null_mut();
    }

    let buffer = unsafe { slice::from_raw_parts(data, len) };

    match load_image_from_memory(buffer) {
        Ok(img) => Box::into_raw(Box::new(img)) as *mut ImageHandle,
        Err(_) => std::ptr::null_mut(),
    }
}

/// Load an image from memory with specific format
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_load_from_memory_with_format(
    data: *const u8,
    len: usize,
    format: ImageFormatEnum,
) -> *mut ImageHandle {
    if data.is_null() || len == 0 {
        return std::ptr::null_mut();
    }

    let buffer = unsafe { slice::from_raw_parts(data, len) };

    match load_image_from_memory_with_format(buffer, format.to_image_format()) {
        Ok(img) => Box::into_raw(Box::new(img)) as *mut ImageHandle,
        Err(_) => std::ptr::null_mut(),
    }
}

// ============================================================================
// Format Detection
// ============================================================================

/// Guess image format from byte data
/// Returns the format enum value or ImageErrorCode on error
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_guess_format(
    data: *const u8,
    len: usize,
    out_format: *mut u32,
) -> ImageErrorCode {
    if data.is_null() || len == 0 || out_format.is_null() {
        return ImageErrorCode::InvalidPointer;
    }

    let buffer = unsafe { slice::from_raw_parts(data, len) };

    match guess_image_format(buffer) {
        Ok(format) => {
            unsafe {
                *out_format = format as u32;
            }
            ImageErrorCode::Success
        }
        Err(e) => error_to_code(&e),
    }
}

// ============================================================================
// Image Saving
// ============================================================================

/// Save an image to a file path
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_save(
    handle: *const ImageHandle,
    path: *const c_char,
) -> ImageErrorCode {
    if handle.is_null() || path.is_null() {
        return ImageErrorCode::InvalidPointer;
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let path_str = unsafe {
        match CStr::from_ptr(path).to_str() {
            Ok(s) => s,
            Err(_) => return ImageErrorCode::InvalidPath,
        }
    };

    match save_image(img, path_str) {
        Ok(_) => ImageErrorCode::Success,
        Err(e) => error_to_code(&e),
    }
}

/// Encode an image to a buffer in the specified format
/// Caller must free the buffer using fast_image_free_buffer
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_encode(
    handle: *const ImageHandle,
    format: ImageFormatEnum,
    out_data: *mut *mut u8,
    out_len: *mut usize,
) -> ImageErrorCode {
    if handle.is_null() || out_data.is_null() || out_len.is_null() {
        return ImageErrorCode::InvalidPointer;
    }

    let img = unsafe { &*(handle as *const DynamicImage) };

    match encode_image(img, format.to_image_format()) {
        Ok(buffer) => {
            let mut boxed = buffer.into_boxed_slice();
            let len = boxed.len();
            let ptr = boxed.as_mut_ptr();
            std::mem::forget(boxed);

            unsafe {
                *out_data = ptr;
                *out_len = len;
            }
            ImageErrorCode::Success
        }
        Err(e) => error_to_code(&e),
    }
}

// ============================================================================
// Image Information
// ============================================================================

/// Get image metadata
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_get_metadata(
    handle: *const ImageHandle,
    out_metadata: *mut ImageMetadata,
) -> ImageErrorCode {
    if handle.is_null() || out_metadata.is_null() {
        return ImageErrorCode::InvalidPointer;
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let metadata = get_metadata(img);

    unsafe {
        *out_metadata = metadata;
    }

    ImageErrorCode::Success
}

// ============================================================================
// Image Transformations
// ============================================================================

/// Resize an image
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_resize(
    handle: *const ImageHandle,
    width: u32,
    height: u32,
    filter: FilterTypeEnum,
) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let resized = resize_image(img, width, height, filter.to_filter_type());

    Box::into_raw(Box::new(resized)) as *mut ImageHandle
}

/// Resize an image to exact dimensions
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_resize_exact(
    handle: *const ImageHandle,
    width: u32,
    height: u32,
    filter: FilterTypeEnum,
) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let resized = resize_exact(img, width, height, filter.to_filter_type());

    Box::into_raw(Box::new(resized)) as *mut ImageHandle
}

/// Resize to fit within dimensions
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_resize_to_fit(
    handle: *const ImageHandle,
    width: u32,
    height: u32,
    filter: FilterTypeEnum,
) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let resized = resize_to_fit(img, width, height, filter.to_filter_type());

    Box::into_raw(Box::new(resized)) as *mut ImageHandle
}

/// Crop an image
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_crop(
    handle: *const ImageHandle,
    x: u32,
    y: u32,
    width: u32,
    height: u32,
) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let cropped = crop_image(img, x, y, width, height);

    Box::into_raw(Box::new(cropped)) as *mut ImageHandle
}

/// Rotate an image 90 degrees clockwise
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_rotate_90(handle: *const ImageHandle) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let rotated = rotate_90(img);

    Box::into_raw(Box::new(rotated)) as *mut ImageHandle
}

/// Rotate an image 180 degrees
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_rotate_180(handle: *const ImageHandle) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let rotated = rotate_180(img);

    Box::into_raw(Box::new(rotated)) as *mut ImageHandle
}

/// Rotate an image 270 degrees clockwise
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_rotate_270(handle: *const ImageHandle) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let rotated = rotate_270(img);

    Box::into_raw(Box::new(rotated)) as *mut ImageHandle
}

/// Flip an image horizontally
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_flip_horizontal(handle: *const ImageHandle) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let flipped = flip_horizontal(img);

    Box::into_raw(Box::new(flipped)) as *mut ImageHandle
}

/// Flip an image vertically
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_flip_vertical(handle: *const ImageHandle) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let flipped = flip_vertical(img);

    Box::into_raw(Box::new(flipped)) as *mut ImageHandle
}

// ============================================================================
// Image Filters & Adjustments
// ============================================================================

/// Blur an image
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_blur(handle: *const ImageHandle, sigma: f32) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let blurred = blur_image(img, sigma);

    Box::into_raw(Box::new(blurred)) as *mut ImageHandle
}

/// Adjust brightness
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_brightness(handle: *const ImageHandle, value: i32) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let adjusted = adjust_brightness(img, value);

    Box::into_raw(Box::new(adjusted)) as *mut ImageHandle
}

/// Adjust contrast
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_contrast(handle: *const ImageHandle, c: f32) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let adjusted = adjust_contrast(img, c);

    Box::into_raw(Box::new(adjusted)) as *mut ImageHandle
}

/// Convert to grayscale
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_grayscale(handle: *const ImageHandle) -> *mut ImageHandle {
    if handle.is_null() {
        return std::ptr::null_mut();
    }

    let img = unsafe { &*(handle as *const DynamicImage) };
    let gray = grayscale(img);

    Box::into_raw(Box::new(gray)) as *mut ImageHandle
}

/// Invert colors (mutates the image)
#[unsafe(no_mangle)]
pub extern "C" fn fast_image_invert(handle: *mut ImageHandle) -> ImageErrorCode {
    if handle.is_null() {
        return ImageErrorCode::InvalidPointer;
    }

    let img = unsafe { &mut *(handle as *mut DynamicImage) };
    invert(img);

    ImageErrorCode::Success
}
