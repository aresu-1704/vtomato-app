import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Utility class for image processing
class ImageUtils {
  /// Fix image orientation based on EXIF data
  /// This prevents images from displaying rotated incorrectly
  static Future<Uint8List> fixOrientation(Uint8List imageBytes) async {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Apply EXIF orientation fix
      // This automatically rotates the image according to EXIF orientation tag
      final fixedImage = img.bakeOrientation(image);

      // CRITICAL: Re-encode WITHOUT EXIF to prevent Flutter from rotating again
      // Clear all EXIF data
      fixedImage.exif.clear();

      // Encode back to JPEG without any metadata
      final encoded = img.encodeJpg(fixedImage, quality: 95);

      print(
        '[DEBUG ImageUtils] Fixed orientation: ${fixedImage.width}x${fixedImage.height}',
      );

      return Uint8List.fromList(encoded);
    } catch (e) {
      print('Error fixing image orientation: $e');
      // Return original if fixing fails
      return imageBytes;
    }
  }

  /// Resize image if too large (for upload optimization)
  static Future<Uint8List> resizeIfNeeded(
    Uint8List imageBytes, {
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Check if resizing is needed
      if (image.width <= maxWidth && image.height <= maxHeight) {
        return imageBytes;
      }

      // Calculate new dimensions maintaining aspect ratio
      final resized = img.copyResize(
        image,
        width: maxWidth,
        height: maxHeight,
        interpolation: img.Interpolation.linear,
      );

      return Uint8List.fromList(img.encodeJpg(resized, quality: 90));
    } catch (e) {
      print('Error resizing image: $e');
      return imageBytes;
    }
  }
}
