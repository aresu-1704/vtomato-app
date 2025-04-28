import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:tomato_detect_app/services/predict_history_repository_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CameraViewModel {
  late CameraController cameraController;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isTakePicture = false;
  bool isCameraInitialized = false;

  Future<void> loadHistory(Function onSetState, int userID) async {
    isLoading = true;
    onSetState();

    await PredictHistoryReposotory
        .fetchHistory(userID)
        .timeout(Duration(seconds: 10));

    isLoading = false;
    onSetState();
  }

  Future<void> initCamera(Function onSetState) async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    await cameraController.initialize();
    isCameraInitialized = true;
    onSetState();
  }

  Future<Uint8List?> takePicture(Function onSetState) async {
      isTakePicture = true;
      onSetState();

      XFile picture = await cameraController.takePicture();
      final imageBytes = await picture.readAsBytes();

      cameraController.setFlashMode(FlashMode.off);

      isTakePicture = false;
      onSetState();

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
    isCameraInitialized = false;
  }
}
