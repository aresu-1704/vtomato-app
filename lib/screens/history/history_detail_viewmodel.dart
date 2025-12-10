import 'package:tomato_detect_app/models/disease_info_model.dart';

class HistoryDetailViewModel {
  final List<DiseaseInfoModel> diseaseInfo;
  final int resultClassCount;

  HistoryDetailViewModel({
    required this.diseaseInfo,
    required this.resultClassCount,
  });

  bool get hasDiseases => resultClassCount > 0;
}
