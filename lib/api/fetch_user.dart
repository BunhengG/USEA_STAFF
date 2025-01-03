import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import '../utils/domain.dart';

/// Logs in the user and returns a [UserItem] on success.
Future<UserItem?> loginUser(String userId, String password) async {
  final String apiUrl = ApiEndpoints.loginUserData;

  Map<String, String> requestBody = {
    'userId': userId,
    'password': password,
  };

  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var responseBody = response.body;

      if (responseBody.isNotEmpty) {
        var jsonData = jsonDecode(responseBody);

        // Check if jsonData is not null before trying to parse
        if (jsonData != null && jsonData is Map<String, dynamic>) {
          return UserItem.fromJson(jsonData);
        } else {
          print('Error: Response body is null or invalid');
        }
      } else {
        print('Error: Empty response body');
      }
    } else {
      print('Failed to log in. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }

  return null;
}
