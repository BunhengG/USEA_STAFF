import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;
import '../helper/shared_pref_helper.dart';
import '../utils/domain.dart';

class CheckInOutProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _shiftStatus;
  String? _shiftType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get shiftStatus => _shiftStatus;
  String? get shiftType => _shiftType;

  final double fixedLatitude = 13.350918350149795;
  final double fixedLongitude = 103.86433962916841;
  final double allowedRange = 10.0;

  // Method to set the shiftStatus and notify listeners
  void setShiftStatus(String status) {
    _shiftStatus = status;
    notifyListeners();
  }

  //! Method to fetch shift data from the backend and update button state

  //
  //
  //
  // ? Start with New Day
  //
  //
  //

  Future<void> updateButtonState(String currentTime, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (userId.isEmpty) {
        _errorMessage = 'User ID is empty. Please log in again.';
        notifyListeners();
        return;
      }

      String getCurrentDateFormatted() {
        final DateTime now = DateTime.now();
        final String formattedDate = DateFormat('dd MMMM yyyy').format(now);
        return formattedDate;
      }

      final currentDate = getCurrentDateFormatted();
      final encodedUserId = Uri.encodeComponent(userId);

      final url =
          Uri.parse('${ApiEndpoints.getShifts}$encodedUserId/$currentDate');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final shiftData = data[0]; // Assuming only one shift record
        final shiftRecord = shiftData['shiftRecord']; // Access shiftRecord

        final firstShift = shiftRecord['firstShift'];
        final secondShift = shiftRecord['secondShift'];

        // Set shift type directly from the backend data
        _shiftType = shiftData['shift']; // "Morning" or "Afternoon"

        // Get today's date to compare with the fetched shift data
        DateTime now = DateTime.now();
        String currentDateString = DateFormat('dd MMMM yyyy').format(now);
        String shiftDateString = shiftData['date'];

        // Reset shift status if it's a new day
        if (currentDateString != shiftDateString) {
          _shiftStatus = 'checkIn';
        } else {
          // Existing shift logic
          if (firstShift['checkIn'] == null) {
            _shiftStatus = 'checkIn'; // First shift, show check-in
          } else if (firstShift['checkIn'] != null &&
              firstShift['checkOut'] == null) {
            _shiftStatus = 'checkOut'; // First shift, show check-out
          } else if (firstShift['checkOut'] != null &&
              secondShift['checkIn'] == null) {
            _shiftStatus = 'checkIn'; // Second shift, show check-in
          } else if (secondShift['checkIn'] != null &&
              secondShift['checkOut'] == null) {
            _shiftStatus = 'checkOut'; // Second shift, show check-out
          } else {
            _shiftStatus = 'disabled';
          }
        }

        notifyListeners();
      } else {
        _errorMessage = 'Failed to fetch shift data.';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkInOut(String qrCode) async {
    if (!qrCode.startsWith('usea') || qrCode.length < 7) {
      _errorMessage = 'Invalid QR code format.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Initialize timezone data for Phnom Penh
      initializeTimeZones();
      final phnomPenh = tz.getLocation('Asia/Phnom_Penh');
      final currentTime = tz.TZDateTime.now(phnomPenh);
      String checkInTime = DateFormat('HH:mm:ss').format(currentTime);

      final userId = await SharedPrefHelper.getUserId();
      if (userId == null) {
        _errorMessage = 'User ID not found. Please log in again.';
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distanceInMeters = Geolocator.distanceBetween(
          position.latitude, position.longitude, fixedLatitude, fixedLongitude);

      if (distanceInMeters > allowedRange) {
        _errorMessage = 'You are not within the allowed range for check-in.';
        notifyListeners();
        return;
      }

      // Validate shift type for check-in/out
      String shift =
          (_shiftType == 'firstShift') ? 'firstShift' : 'secondShift';

      Map<String, dynamic> requestBody = {
        "userId": userId,
        "shift": shift,
        "checkInTime": checkInTime,
      };

      var response = await http.post(
        Uri.parse(ApiEndpoints.getCheckInOut),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        _errorMessage = null;

        // Parse the response body to get shift data
        final data = jsonDecode(response.body);

        String shiftStatus;

        // Check if first shift is completed
        if (data['shiftRecord']['firstShift']['checkIn'] != null &&
            data['shiftRecord']['firstShift']['checkOut'] != null) {
          // If first shift is completed, move to second shift
          if (data['shiftRecord']['secondShift']['checkIn'] == null) {
            shiftStatus = 'checkIn'; // Allow check-in for second shift
          } else if (data['shiftRecord']['secondShift']['checkOut'] == null) {
            shiftStatus = 'checkOut'; // Allow check-out for second shift
          } else {
            shiftStatus = 'disabled';
          }
        } else {
          // Allow check-in and check-out for first shift
          if (data['shiftRecord']['firstShift']['checkIn'] == null) {
            shiftStatus = 'checkIn'; // Allow check-in for first shift
          } else if (data['shiftRecord']['firstShift']['checkOut'] == null) {
            shiftStatus = 'checkOut'; // Allow check-out for first shift
          } else {
            shiftStatus = 'disabled';
          }
        }

        setShiftStatus(shiftStatus);
      } else {
        _errorMessage = 'Error: ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
