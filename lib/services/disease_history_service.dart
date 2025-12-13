import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:vtomato_app/constants/api_constant.dart';
import 'package:vtomato_app/models/disease_history_model.dart';

class DiseaseHistoryService {
  Future<bool> saveDiseaseHistory(
    Uint8List imageBytes,
    String userID,
    List<int> classList,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/disease-history/save');

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['UserID'] = userID.toString();
      request.fields['ClassIdxList'] = json.encode(classList);
      request.files.add(
        http.MultipartFile.fromBytes(
          'Image',
          imageBytes,
          filename: 'history.jpg',
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);

      return data['Reload_Status'] ?? false;
    } catch (e) {
      print('Lỗi khi lưu lịch sử: $e');
      return false;
    }
  }

  Future<List<DiseaseHistoryModel>> getHistoryByUser(String userID) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/disease-history/$userID');

    try {
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('API request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['history'] != null) {
          final historyList = <DiseaseHistoryModel>[];
          for (var i = 0; i < (data['history'] as List).length; i++) {
            try {
              final item = DiseaseHistoryModel.fromJson(data['history'][i]);
              historyList.add(item);
            } catch (_) {}
          }
          return historyList;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }
}
