import 'package:tomato_detect_app/models/DiseaseHistory.dart';
import 'package:tomato_detect_app/repositories/disease_history_repository.dart';

class PredictsHistoryViewModel {
  bool isLoading = true;
  List<DiseaseHistory> historyList = [];

  PredictsHistoryViewModel() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    isLoading = true;

    historyList = DiseaseHistoryRepository.listDiseaseHistory;

    isLoading = false;
  }
}
