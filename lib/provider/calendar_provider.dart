import 'package:flutter/material.dart';
import 'package:usea_staff_test/model/calendar.dart';
import '../helper/shared_pref_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/domain.dart';

class CalendarProvider with ChangeNotifier {
  // Calendar Data
  List<CalendarItem> _calendars = [];
  List<CalendarItem> get calendars => _calendars;

  // Holiday Data
  List<dynamic> _holidays = [];
  List<dynamic> get holidays => _holidays;

  // Loading & Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  //NOTE: Fetch Holidays Data for specific month and year
  Future<void> fetchHolidaysForMonth(int month, int year) async {
    _setLoadingState(true);

    try {
      final url = Uri.parse(
        '${ApiEndpoints.getHolidays}/$year?month=$month',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _holidays = json.decode(response.body);
      } else {
        _setErrorState('Failed to fetch holidays for $month/$year');
      }
    } catch (e) {
      _setErrorState('Error fetching holidays: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  //NOTE: Fetch Calendar Data
  Future<void> fetchCalendars() async {
    _setLoadingState(true);

    try {
      final userId = await _getUserId();
      if (userId == null) return;

      final url = Uri.parse(
        '${ApiEndpoints.getCalendars}${Uri.encodeComponent(userId)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _calendars = _parseCalendarData(response.body);
      } else {
        _setErrorState('Failed to load calendars: ${response.statusCode}');
      }
    } catch (error) {
      _setErrorState('Error fetching calendars: $error');
    } finally {
      _setLoadingState(false);
    }
  }

  //NOTE: Refresh Both Holidays and Calendars
  Future<void> refreshData() async {
    await fetchHolidaysForMonth(DateTime.now().month, DateTime.now().year);
    await fetchCalendars();
  }

  // Helper methods
  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    _notifyListeners();
  }

  void _setErrorState(String message) {
    _errorMessage = message;
    _notifyListeners();
  }

  List<CalendarItem> _parseCalendarData(String responseBody) {
    final List<dynamic> data = json.decode(responseBody);
    return data.map((json) => CalendarItem.fromJson(json)).toList();
  }

  Future<String?> _getUserId() async {
    final userId = await SharedPrefHelper.getUserId();
    if (userId == null) {
      _setErrorState('User ID not found in Shared Preferences');
    }
    return userId;
  }

  void _notifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
