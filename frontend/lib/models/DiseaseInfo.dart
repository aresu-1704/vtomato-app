class DiseaseInfo {
  final String diseaseName;
  final String cause;
  final String symptoms;
  final String conditions;
  final String treatment;

  DiseaseInfo({
    required this.diseaseName,
    required this.cause,
    required this.symptoms,
    required this.conditions,
    required this.treatment,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
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
