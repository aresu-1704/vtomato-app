import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:tomato_detect_app/services/predict_history_repository_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CameraViewModel {
  late CameraController cameraController;
  final ImagePicker _picker = ImagePicker();

  Future<void> loadHistory(Function(bool) onLoadingChange, int userID) async {
    onLoadingChange(true);

    await PredictHistoryReposotory
        .fetchHistory(userID)
        .timeout(Duration(seconds: 10));

    onLoadingChange(false);
  }

  Future<void> initCamera(Function(bool) onCameraInitializedChange) async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    await cameraController.initialize();
    onCameraInitializedChange(true);
  }

  Future<Uint8List?> takePicture(Function(bool) onTakePictureChange) async {
      onTakePictureChange(true);

      XFile picture = await cameraController.takePicture();
      final imageBytes = await picture.readAsBytes();

      cameraController.setFlashMode(FlashMode.off);

      onTakePictureChange(false);

      return imageBytes;
  }

  Future<Uint8List?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        return null;
      }

      img.Image rotatedImage = img.copyRotate(originalImage, angle: -90);

      final Uint8List rotatedBytes = Uint8List.fromList(img.encodeJpg(rotatedImage));

      return rotatedBytes;
    } else {
      return null;
    }
  }

  void dispose() {
    cameraController.setFlashMode(FlashMode.off);
    cameraController.dispose();
  }
}
