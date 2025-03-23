import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:japx/japx.dart';

class ApiService {
  static const String baseUrl = "https://test.myfliqapp.com/api/v1";

  /// Send OTP

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final url = Uri.parse(
      "$baseUrl/auth/registration-otp-codes/actions/phone/send-otp",
    );

    Map<String, dynamic> requestData = {
      "data": {
        "type": "registration_otp_codes",
        "attributes": {"phone": phone},
      },
    };

    print("Request Data: ${jsonEncode(requestData)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['data'] is int) {
        return {'otp': jsonResponse['data']};
      } else {
        return jsonResponse['data'];
      }
    } else {
      throw Exception("Failed to send OTP");
    }
  }

  /// Verify OTP
  static Future<String?> verifyOtp(String phone, String otp) async {
    final url = Uri.parse(
      "${baseUrl}/auth/registration-otp-codes/actions/phone/verify-otp",
    );

    final Map<String, dynamic> requestData = {
      "data": {
        "type": "registration_otp_codes",
        "attributes": {
          "phone": phone,
          "otp": 111111,
          "device_meta": {
            "type": "web",
            "name": "HP Pavilion 14-EP0068TU",
            "os": "Linux x86_64",
            "browser": "Mozilla Firefox Snap for Ubuntu (64-bit)",
            "browser_version": "112.0.2",
            "user_agent":
                "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/112.0",
            "screen_resolution": "1600x900",
            "language": "en-GB",
          },
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestData),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String? token =
            jsonResponse['data']['attributes']['auth_status']['access_token'];
        if (token != null) {
          return token;
        } else {
          print("Token not found in the response");
          return null;
        }
      } else {
        print("Failed to verify OTP. Status Code: ${response.statusCode}");
        print("Error Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during OTP verification: $e");
      return null;
    }
  }

  /// Get Chat List
  static Future<List<dynamic>> getChatList(String token) async {
    final url = Uri.parse("$baseUrl/chat/chat-messages/queries/contact-users");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final decodedData = Japx.decode(data);
        return decodedData['data'];
      } else {
        throw Exception(
          "Failed to load chat list. Status code: ${response.statusCode}",
        );
      }
    } catch (error) {
      print("Error fetching chat list: $error");
      rethrow;
    }
  }

  /// Get Chat Between Users
  static Future<List<dynamic>> getChatBetweenUsers(
    int senderId,
    String receiverId,
    String token,
  ) async {
    final url = Uri.parse(
      "$baseUrl/chat/chat-messages/queries/chat-between-users/$senderId/$receiverId",
    );

    final response = await http.get(url,
    headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final decodedData = Japx.decode(jsonResponse);
      return decodedData['data'];
    } else {
      throw Exception("Failed to load messages");
    }
  }
}
