import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // 🚀 Fetch Attendance Data
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

  // 🚀 Add or Update Attendance
  Future<void> updateAttendance({
    required String userId,
    required String date,
    ShiftDetails? firstShiftCheckIn,
    ShiftDetails? firstShiftCheckOut,
    ShiftDetails? secondShiftCheckIn,
    ShiftDetails? secondShiftCheckOut,
    required String attendStatus,
  }) async {
    _setLoadingState(true);

    try {
      DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      final url = Uri.parse(
        '${ApiEndpoints.getAttendances}${Uri.encodeComponent(userId)}',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'date': formattedDate,
          'shiftRecord': {
            'firstShift': firstShiftCheckIn?.toJson(),
            'secondShift': secondShiftCheckOut?.toJson(),
            // Add additional shifts as required
          },
          'attendStatus': attendStatus,
        }),
      );

      if (response.statusCode == 200) {
        await fetchAttendances();
      } else {
        final errorResponse = jsonDecode(response.body);
        _setErrorState(
            'Failed to update attendance: ${errorResponse['message']}');
      }
    } catch (error) {
      _setErrorState('Error updating attendance: $error');
    } finally {
      _setLoadingState(false);
    }
  }

  /// Helper: Handle Loading State
  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    _notifyListeners();
  }

  /// Helper: Handle Error State
  void _setErrorState(String message) {
    _errorMessage = message;
    _notifyListeners();
  }

  /// Helper: Parse JSON Data into AttendanceItems
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

  /// Clear Attendance Data
  void clearAttendances() {
    _attendances = [];
    _notifyListeners();
  }

  /// Notify Listeners Safely
  void _notifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
