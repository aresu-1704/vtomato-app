import 'package:tomato_detect_app/models/DiseaseHistory.dart';
import 'package:tomato_detect_app/services/disease_history_service.dart';

class PredictHistoryReposotory {
  static List<DiseaseHistory> listDiseaseHistory = [];

  static Future<void> fetchHistory(int userID) async {
    final _diseaseHistoryService = DiseaseHistoryService();

    listDiseaseHistory = await _diseaseHistoryService.getHistoryByUser(userID);
  }
}