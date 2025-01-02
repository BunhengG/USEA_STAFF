import 'package:get/get.dart';

class ApiEndpoints {
  // Define both Khmer and English base URLs
  static const String _baseKHUrl = 'http://192.168.1.57:3000/';
  static const String _baseENUrl = 'http://192.168.1.57:3000/';

  // Method to get the base URL based on the current locale or language code
  static String get _baseUrl {
    String languageCode = Get.locale?.languageCode ?? 'km';
    return languageCode == 'en' ? _baseENUrl : _baseKHUrl;
  }

  // API Endpoints with dynamic base URL based on language code
  static String get loginUserData => '${_baseUrl}login';
  static String get getUsers => '${_baseUrl}users';
  static String get getAttendances => '${_baseUrl}attendances/';
  static String get getPermissions => '${_baseUrl}permissions/';
  static String get getMembers => '${_baseUrl}members';
}
