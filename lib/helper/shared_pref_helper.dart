import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // Defined keys
  static const String userIdKey = 'userId';
  static const String passwordKey = 'password';

  /// Save userId and Password
  static Future<void> saveUserIdAndPassword(
      String userId, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
    await prefs.setString(passwordKey, password);
  }

  /// Get userId
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  /// Get Password
  static Future<String?> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(passwordKey);
  }

  /// Clear All User Data (for Logout)
  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
