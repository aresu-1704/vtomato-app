import 'package:flutter/material.dart';

class Detection {
  final List<double> bbox; // [x1, y1, x2, y2]
  final int classId;
  final String className;
  final double confidence;

  Detection({
    required this.bbox,
    required this.classId,
    required this.className,
    required this.confidence,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      bbox: List<double>.from(json['bbox']),
      classId: json['class_id'],
      className: json['class_name'],
      confidence: json['confidence'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bbox': bbox,
      'class_id': classId,
      'class_name': className,
      'confidence': confidence,
    };
  }
}

class DetectionResult {
  final List<Detection> detections;
  final Size imageSize;
  final List<int> classIndices;

  DetectionResult({
    required this.detections,
    required this.imageSize,
    required this.classIndices,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    final imageSizeData = json['image_size'];
    return DetectionResult(
      detections:
          (json['detections'] as List)
              .map((d) => Detection.fromJson(d))
              .toList(),
      imageSize: Size(
        imageSizeData['width'].toDouble(),
        imageSizeData['height'].toDouble(),
      ),
      classIndices: List<int>.from(json['class_indices']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detections': detections.map((d) => d.toJson()).toList(),
      'image_size': {'width': imageSize.width, 'height': imageSize.height},
      'class_indices': classIndices,
    };
  }
}
