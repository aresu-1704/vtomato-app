import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vtomato_app/constants/api_constant.dart';

class AuthService {
  Future<String> login(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Email": email, "Password": password}),
      );

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body);

        if (message['message'] == "Login successful") {
          final userId = message['UserID']?.toString();
          if (userId != null && userId.isNotEmpty) return userId;
        }
        throw Exception('Đăng nhập thất bại: Phản hồi không hợp lệ.');
      } else if (response.statusCode == 429) {
        throw Exception(
          'Bạn đã đăng nhập quá nhiều lần, vui lòng thử lại sau.',
        );
      } else {
        throw Exception('Sai tài khoản hoặc mật khẩu.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ, vui lòng thử lại sau.');
    } catch (ex) {
      // Re-throw if it's already an Exception we threw above, otherwise wrap
      if (ex.toString().contains('Exception:')) throw ex;
      throw Exception('Lỗi: $ex');
    }
  }

  Future<void> register(
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Email": email,
          "PhoneNumber": phoneNumber,
          "Password": password,
        }),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Đăng ký thất bại.');
      }
    } on SocketException {
      throw Exception("Lỗi kết nối mạng.");
    } catch (ex) {
      if (ex.toString().contains('Exception:')) throw ex;
      throw Exception('Lỗi: $ex');
    }
  }

  Future<int> sendOTPtoemail(String email) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/send-otp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Email": email}),
      );

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body);
        final userId = int.tryParse(message['UserID'].toString());
        if (userId != null) return userId;
        throw Exception('Phản hồi từ máy chủ không hợp lệ.');
      } else if (response.statusCode == 401) {
        throw Exception('Email không tồn tại hoặc lỗi xác thực.');
      } else {
        throw Exception('Gửi OTP thất bại. Mã lỗi: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ.');
    } catch (ex) {
      if (ex.toString().contains('Exception:')) throw ex;
      throw Exception('Lỗi: $ex');
    }
  }

  Future<void> verifyOTP(int userID, int otp) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userID, "OTP": otp}),
      );

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body);
        final msgText = message['Message'];
        if (msgText == "OTP verified successfully!") {
          return;
        } else if (msgText == "Invalid OTP.") {
          throw Exception('Mã OTP không đúng.');
        } else if (msgText == "OTP has expired or does not exist.") {
          throw Exception('Mã OTP đã hết hạn hoặc không tồn tại.');
        } else {
          throw Exception('Xác minh thất bại: $msgText');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Lỗi xác thực (401).');
      } else {
        throw Exception('Lỗi máy chủ: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Lỗi kết nối mạng.');
    } catch (ex) {
      if (ex.toString().contains('Exception:')) throw ex;
      throw Exception('Lỗi: $ex');
    }
  }

  Future<void> resetPassword(int userID, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/$userID');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"NewPassword": password}),
      );

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body);
        if (message['message'] == "Password reset successful") {
          return;
        }
        throw Exception('Khôi phục mật khẩu thất bại.');
      } else {
        throw Exception('Lỗi máy chủ: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Lỗi kết nối mạng.');
    } catch (ex) {
      if (ex.toString().contains('Exception:')) throw ex;
      throw Exception('Lỗi: $ex');
    }
  }
}
