import 'package:tomato_detect_app/models/DiseaseInfo.dart';

class HistoryDetailViewModel {
  final List<DiseaseInfo> diseaseInfo;
  final int resultClassCount;

  HistoryDetailViewModel({
    required this.diseaseInfo,
    required this.resultClassCount,
  });

  bool get hasDiseases => resultClassCount > 0;
}
