class DiseaseInfoModel {
  final String diseaseName;
  final String cause;
  final String symptoms;
  final String conditions;
  final String treatment;

  DiseaseInfoModel({
    required this.diseaseName,
    required this.cause,
    required this.symptoms,
    required this.conditions,
    required this.treatment,
  });

  factory DiseaseInfoModel.fromJson(Map<String, dynamic> json) {
    return DiseaseInfoModel(
      diseaseName: json['DiseaseName'] ?? '',
      cause: json['Cause'] ?? '',
      symptoms: json['Symptoms'] ?? '',
      conditions: json['Conditions'] ?? '',
      treatment: json['Treatment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DiseaseName': diseaseName,
      'Cause': cause,
      'Symptoms': symptoms,
      'Conditions': conditions,
      'Treatment': treatment,
    };
  }
}
