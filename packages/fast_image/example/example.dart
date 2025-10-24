import 'package:fast_image/fast_image.dart';

void main() {
  // Example 1: Load, resize, and save an image
  print('Example 1: Basic image manipulation');
  final image = FastImage.fromFile('input.jpg');
  
  // Get metadata
  final metadata = image.getMetadata();
  print('Original size: ${metadata.width}x${metadata.height}');
  print('Color type: ${metadata.colorType.name}');
  
  // Resize maintaining aspect ratio
  final resized = image.resize(800, 600);
  resized.saveToFile('output_resized.jpg');
  print('Resized and saved to output_resized.jpg');
  
  // Clean up
  resized.dispose();
  image.dispose();
  
  // Example 2: Apply filters
  print('\nExample 2: Apply filters');
  final image2 = FastImage.fromFile('input.png');
  
  // Apply blur
  final blurred = image2.blur(2.5);
  blurred.saveToFile('output_blurred.png');
  
  // Convert to grayscale
  final gray = image2.grayscale();
  gray.saveToFile('output_grayscale.png');
  
  // Adjust brightness
  final brightened = image2.brightness(30);
  brightened.saveToFile('output_brightened.png');
  
  // Adjust contrast
  final contrasted = image2.contrast(1.5);
  contrasted.saveToFile('output_contrasted.png');
  
  // Clean up
  blurred.dispose();
  gray.dispose();
  brightened.dispose();
  contrasted.dispose();
  image2.dispose();
  
  // Example 3: Transformations
  print('\nExample 3: Transformations');
  final image3 = FastImage.fromFile('input.jpg');
  
  // Rotate
  final rotated = image3.rotate90();
  rotated.saveToFile('output_rotated.jpg');
  
  // Flip
  final flipped = image3.flipHorizontal();
  flipped.saveToFile('output_flipped.jpg');
  
  // Crop
  final cropped = image3.crop(100, 100, 400, 300);
  cropped.saveToFile('output_cropped.jpg');
  
  // Clean up
  rotated.dispose();
  flipped.dispose();
  cropped.dispose();
  image3.dispose();
  
  // Example 4: Encode to memory
  print('\nExample 4: Encode to memory');
  final image4 = FastImage.fromFile('input.jpg');
  
  // Encode as PNG
  final pngBytes = image4.encode(ImageFormatEnum.Png);
  print('Encoded as PNG: ${pngBytes.length} bytes');
  
  // Encode as WebP
  final webpBytes = image4.encode(ImageFormatEnum.WebP);
  print('Encoded as WebP: ${webpBytes.length} bytes');
  
  image4.dispose();
  
  // Example 5: Load from memory
  print('\nExample 5: Load from memory');
  final imageFromMemory = FastImage.fromMemory(pngBytes);
  print('Loaded from memory: ${imageFromMemory.width}x${imageFromMemory.height}');
  imageFromMemory.dispose();
  
  // Example 6: Chain operations
  print('\nExample 6: Chain operations');
  final image6 = FastImage.fromFile('input.jpg');
  final processed = image6
      .resize(1024, 768)
      .brightness(10)
      .contrast(1.2)
      .blur(0.5);
  
  processed.saveToFile('output_processed.jpg');
  
  // Clean up (need to dispose each intermediate image)
  // In a real app, you'd want to track and dispose each step
  processed.dispose();
  image6.dispose();
  
  // Example 7: Error handling
  print('\nExample 7: Error handling');
  try {
    final invalid = FastImage.fromFile('nonexistent.jpg');
    invalid.dispose();
  } on LoadException catch (e) {
    print('Caught expected error: $e');
  }
  
  // Example 8: In-place mutation (invert)
  print('\nExample 8: In-place mutation');
  final image8 = FastImage.fromFile('input.jpg');
  image8.invert(); // This mutates the image
  image8.saveToFile('output_inverted.jpg');
  image8.dispose();
  
  print('\nAll examples completed!');
}
