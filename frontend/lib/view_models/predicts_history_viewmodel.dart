import 'package:tomato_detect_app/models/DiseaseHistory.dart';
import 'package:tomato_detect_app/services/predict_history_repository_service.dart';

class PredictsHistoryViewModel {
  bool isLoading = true;
  List<DiseaseHistory> historyList = [];

  PredictsHistoryViewModel() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    isLoading = true;

    historyList = PredictHistoryReposotory.listDiseaseHistory;

    isLoading = false;
  }
}
