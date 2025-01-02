import 'package:flutter/material.dart';
import '../helper/shared_pref_helper.dart';
import '../model/attendance.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/domain.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceItem> _attendances = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceItem> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //NOTE: Fetch Attendance Data
  Future<void> fetchAttendances() async {
    _setLoadingState(true);

    try {
      final userId = await _getUserId();
      if (userId == null) return;

      final url = Uri.parse(
        '${ApiEndpoints.getAttendances}${Uri.encodeComponent(userId)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _attendances = _parseAttendanceData(response.body);
      } else {
        _setErrorState('Failed to load attendances: ${response.statusCode}');
      }
    } catch (error) {
      _setErrorState('Error fetching attendances: $error');
    } finally {
      _setLoadingState(false);
    }
  }

  /// Helper method to handle loading state
  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    _notifyListeners();
  }

  /// Helper method to handle error state
  void _setErrorState(String message) {
    _errorMessage = message;
    _notifyListeners();
  }

  /// Helper method to parse JSON data into AttendanceItems
  List<AttendanceItem> _parseAttendanceData(String responseBody) {
    final List<dynamic> data = json.decode(responseBody);
    return data.map((json) => AttendanceItem.fromJson(json)).toList();
  }

  /// Get userId from SharedPreferences
  Future<String?> _getUserId() async {
    final userId = await SharedPrefHelper.getUserId();
    if (userId == null) {
      _setErrorState('User ID not found in Shared Preferences');
    }
    return userId;
  }

  /// Notify listeners after the current build cycle
  void _notifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Clear Attendance Data
  void clearAttendances() {
    _attendances = [];
    _notifyListeners();
  }
}
