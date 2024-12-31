import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import '../utils/domain.dart';

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

        if (jsonData != null) {
          return UserItem.fromMap(jsonData);
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
