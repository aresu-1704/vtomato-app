import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tomato_detect_app/constants/api_constant.dart';
import 'package:tomato_detect_app/models/DiseaseHistory.dart';

class DiseaseHistoryService {
  Future<bool> saveDiseaseHistory(Uint8List imageBytes, int userID, List<int> classList) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/disease-history/save');
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "UserID": userID,
        "Image": base64Image,
        "ClassIdxList": classList
      }),
    );

    if (response.statusCode == 200) {
      final message = jsonDecode(response.body);
      return message['Reload_Status'];
    } else {
      final data = jsonDecode(response.body);
      return data['Reload_Status'];
    }
  }

  Future<List<DiseaseHistory>> getHistoryByUser(int userID) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/disease-history/$userID');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['history'] != null) {
          return (data['history'] as List)
              .map((json) => DiseaseHistory.fromJson(json))
              .toList();
        } else {
          print("No 'history' key in response.");
          return [];
        }
      } else {
        print("Server error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception occurred in getHistoryByUser: $e");
      return [];
    }
  }
}