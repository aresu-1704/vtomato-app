import 'dart:typed_data';
import 'package:tomato_detect_app/models/disease_info_model.dart';
import 'package:tomato_detect_app/services/predict_service.dart';
import 'package:tomato_detect_app/services/disease_history_service.dart';

class PredictResultViewModel {
  final PredictService _predictService = PredictService();
  final DiseaseHistoryService _diseaseHistoryService = DiseaseHistoryService();

  Uint8List? resultImage;
  int? resultClassCount = 0;
  List<int> resultClassList = [];
  List<DiseaseInfoModel> _diseaseInfo = [];
  bool isLoading = true;
  String? message;

  Future<void> handlePrediction(Uint8List image) async {
    // Step 1: Upload image and get annotated result with class_indices
    final result = await _predictService.uploadImageForPrediction(image);

    if (result == null) {
      message = "Có lỗi xảy ra khi xử lý ảnh.";
      isLoading = false;
      return;
    }

    if (result['status'] == 'success') {
      resultImage = result['image'];
      resultClassCount = result['class_count'];
      resultClassList = List<int>.from(result['class_indices']);

      // Step 2: Get disease info if diseases detected
      if (resultClassList.isNotEmpty) {
        final diseaseInfo = await _predictService.getDiseaseInfo(
          resultClassList,
        );
        if (diseaseInfo != null) {
          _diseaseInfo = diseaseInfo;
        } else {
          message = "Không thể lấy thông tin bệnh.";
        }
      } else {
        message = "Không phát hiện bệnh nào.";
      }

      isLoading = false;
    } else {
      message = "Có lỗi xảy ra khi xử lý ảnh.";
      isLoading = false;
    }
  }

  Future<void> saveHistory(int userID) async {
    bool reloadStatus = await _diseaseHistoryService.saveDiseaseHistory(
      resultImage!,
      userID,
      resultClassList,
    );

    isLoading = true;

    if (reloadStatus) {
      // History will be reloaded when navigating to history screen
    }

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
  }

  List<DiseaseInfoModel> get diseaseInfo => _diseaseInfo;
}
