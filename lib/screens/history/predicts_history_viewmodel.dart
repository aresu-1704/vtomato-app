import 'package:tomato_detect_app/models/disease_history_model.dart';
import 'package:tomato_detect_app/services/disease_history_service.dart';

class PredictsHistoryViewModel {
  bool isLoading = true;
  List<DiseaseHistoryModel> historyList = [];
  final DiseaseHistoryService _service = DiseaseHistoryService();

  Future<void> loadHistory(int userID) async {
    isLoading = true;
    historyList = await _service.getHistoryByUser(userID);
    isLoading = false;
  }
}
