cd native
cbindgen -l c --output ../packages/fast_image/native/include/fast_image.h

cd ..
cd packages/fast_image
dart run ffigen --config ffigen.yaml