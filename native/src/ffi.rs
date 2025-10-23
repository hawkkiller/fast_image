#[unsafe(no_mangle)]
pub extern "C" fn hello_from_rust() -> *const u8 {
    b"Hello from Rust!\0".as_ptr()
}
