import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helper/shared_pref_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/shift.dart';
import '../utils/domain.dart';

class ShiftDetailsProvider with ChangeNotifier {
  ShiftSummary? _shiftSummary; // Store ShiftSummary object
  bool _isLoading = false;
  String? _errorMessage;

  ShiftSummary? get shiftSummary => _shiftSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch Shift Details Data
  Future<void> fetchShiftDetails() async {
    _setLoadingState(true);

    try {
      final userId = await _getUserId();
      if (userId == null) return;

      String getCurrentDateFormatted() {
        final DateTime now = DateTime.now();
        final String formattedDate = DateFormat('dd MMMM yyyy').format(now);
        return formattedDate;
      }

      final currentDate = getCurrentDateFormatted();
      final encodedUserId = Uri.encodeComponent(userId);

      final url = Uri.parse(
        '${ApiEndpoints.getSingleShifts}$encodedUserId/$currentDate',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        _shiftSummary = _parseShiftSummary(response.body);
        _setErrorState(null);
      } else {
        _setErrorState('Failed to load shift details: ${response.statusCode}');
      }
    } catch (error) {
      _setErrorState('Error fetching shift details: $error');
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
  void _setErrorState(String? message) {
    _errorMessage = message;
    _notifyListeners();
  }

  /// Helper method to parse JSON data into ShiftSummary
  ShiftSummary _parseShiftSummary(String responseBody) {
    final Map<String, dynamic> data = json.decode(responseBody);
    return ShiftSummary.fromJson(data);
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

  /// Clear ShiftSummary Data
  void clearShiftSummary() {
    _shiftSummary = null;
    _notifyListeners();
  }
}
