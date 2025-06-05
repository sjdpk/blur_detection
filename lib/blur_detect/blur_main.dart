import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:blur_detection/blur_detect/blur_algorithm.dart';
import 'package:blur_detection/blur_detect/compression.dart';

class BlurMain {
  static Future<bool> isImageBlurred(File selectedFile) async {
    File? copiedFile;
    File? compressedFile;
    try {
      // Step 1: Copy the file
      String copiedFilePath = '${selectedFile.path}_copy.jpg';
      copiedFile = await selectedFile.copy(copiedFilePath);

      // Step 2: Compress the copied image
      compressedFile =
          await ImgCompression.imageCompression(picture: copiedFile);

      // Step 3: Evaluate blurriness on the compressed image
      bool isImageBlur = await evaluateImageSharpness(compressedFile);

      return isImageBlur;
    } catch (e) {
      // Handle errors (e.g., file not found or compression issues)
      return false;
    } finally {
      // Clean up temporary files in finally block to ensure cleanup happens
      try {
        if (copiedFile != null && await copiedFile.exists()) {
          await copiedFile.delete();
        }
        if (compressedFile != null && 
            compressedFile.path != copiedFile?.path && 
            await compressedFile.exists()) {
          await compressedFile.delete();
        }
      } catch (cleanupError) {
        // Log cleanup error but don't affect the main result
        log('Cleanup error: $cleanupError');
      }
    }
  }
}
