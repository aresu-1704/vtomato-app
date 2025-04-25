import 'dart:typed_data';
import 'package:tomato_detect_app/models/DiseaseInfo.dart';
import 'package:tomato_detect_app/services/predict_service.dart';
import 'package:tomato_detect_app/services/disease_history_service.dart';
import 'package:tomato_detect_app/services/predict_history_repository_service.dart';

class PredictResultViewModel {
  final PredictService _predictService = PredictService();
  final DiseaseHistoryService _diseaseHistoryService = DiseaseHistoryService();

  Uint8List? resultImage;
  int? resultClassCount = 0;
  List<int> resultClassList = [];
  List<DiseaseInfo> _diseaseInfo = [];
  bool isLoading = true;
  String? message;

  Future<void> handlePrediction(Uint8List image) async {
    final result = await _predictService.sendImage(image);

    if (result == null) {
      message = "Có lỗi xảy ra khi xử lý ảnh.";
      isLoading = false;
      return;
    }

    if (result['status'] == 'no_disease') {
      message = result['message'] ?? "Không phát hiện bệnh.";
      isLoading = false;
    } else {
      resultImage = result['image'];
      resultClassCount = result['class_count'];
      resultClassList = List<int>.from(result['class_indices']);
      _diseaseInfo = List<DiseaseInfo>.from(result['disease_info']);
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
      await PredictHistoryReposotory.fetchHistory(userID);
    }

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
  }

  List<DiseaseInfo> get diseaseInfo => _diseaseInfo;
}
