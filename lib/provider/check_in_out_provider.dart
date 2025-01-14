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
  final double allowedRange = 50.0;

  // Initialize time zones
  late tz.Location phnomPenh;

  CheckInOutProvider() {
    initializeTimeZones();
    phnomPenh = tz.getLocation('Asia/Phnom_Penh');
  }

  // Method to set the shiftStatus and notify listeners
  void setShiftStatus(String status) {
    _shiftStatus = status;
    notifyListeners();
  }

  // Helper method to get the current date formatted
  String getCurrentDateFormatted() {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('dd MMMM yyyy').format(now);
    return formattedDate;
  }

  //NOTE: Update button state based on current time and shift
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

      final currentDate = getCurrentDateFormatted();
      final encodedUserId = Uri.encodeComponent(userId);

      final url =
          Uri.parse('${ApiEndpoints.getShifts}$encodedUserId/$currentDate');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shiftData = data[0];
        final shiftRecord = shiftData['shiftRecord'];
        final firstShift = shiftRecord['firstShift'];
        final secondShift = shiftRecord['secondShift'];

        _shiftType = shiftData['shift'];

        tz.TZDateTime now = tz.TZDateTime.now(phnomPenh);
        String currentDateString = DateFormat('dd MMMM yyyy').format(now);
        String shiftDateString = shiftData['date'];

        if (currentDateString != shiftDateString) {
          _shiftStatus = 'checkIn';
        } else {
          if (firstShift['checkIn'] == null) {
            _shiftStatus = 'checkIn';
          } else if (firstShift['checkOut'] == null) {
            _shiftStatus = 'checkOut';
          } else if (secondShift['checkIn'] == null) {
            _shiftStatus = 'checkIn';
          } else if (secondShift['checkOut'] == null) {
            _shiftStatus = 'checkOut';
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

  //* Checking if check-in is late
  bool get shouldShowCheckInReason {
    tz.TZDateTime currentTime = tz.TZDateTime.now(phnomPenh);

    // Define first shift start time
    tz.TZDateTime firstShiftStart = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 7, 0); // 07:00 AM

    // Define second shift start time
    tz.TZDateTime secondShiftStart = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 14, 0); // 02:00 PM

    // Check if it's late for the first shift
    if (currentTime.isAfter(firstShiftStart) &&
        currentTime.isBefore(firstShiftStart.add(const Duration(hours: 5)))) {
      return true;
    }

    // Check if it's late for the second shift
    if (currentTime.isAfter(secondShiftStart) &&
        currentTime.isBefore(secondShiftStart.add(const Duration(hours: 3)))) {
      return true;
    }

    return false;
  }

  //* Checking if check-out is early
// Checking if check-out is early and requiring reason during specified times
  bool get shouldShowCheckOutReason {
    tz.TZDateTime currentTime = tz.TZDateTime.now(phnomPenh);

    // Define first shift boundaries (in local time)
    tz.TZDateTime firstShiftStart = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 7, 0); // 07:00 AM
    tz.TZDateTime firstShiftEnd = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 12, 0); // 12:00 PM

    // Define second shift boundaries (in local time)
    tz.TZDateTime secondShiftStart = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 14, 0); // 02:00 PM
    tz.TZDateTime secondShiftEnd = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 17, 0); // 05:00 PM

    // Check for early check-out reasons
    if (currentTime.isAfter(firstShiftStart) &&
        currentTime.isBefore(firstShiftEnd)) {
      return true; // Reason required if check-out is between 7:00 AM and 12:00 PM
    }
    if (currentTime.isAfter(secondShiftStart) &&
        currentTime.isBefore(secondShiftEnd)) {
      return true; // Reason required if check-out is between 2:00 PM and 5:00 PM
    }

    return false;
  }

  //NOTE: Check in and out of the specified
  Future<void> checkInOut(String qrCode, {required String reason}) async {
    if (!qrCode.startsWith('usea') || qrCode.length < 7) {
      _errorMessage = 'Invalid QR code format.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // for Phnom Penh
      initializeTimeZones();
      tz.TZDateTime currentTime = tz.TZDateTime.now(phnomPenh);
      String checkInTime = DateFormat('HH:mm:ss').format(currentTime);
      String checkOutTime = DateFormat('HH:mm:ss').format(currentTime);

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

      // Validate early check-out and show modal for reasons only if necessary
      if (_shiftStatus == 'checkOut') {
        if (_shiftType == 'firstShift') {
          final checkOutTimeParsed = DateFormat('HH:mm').parse(checkOutTime);

          // Check-out before 12:00 PM requires reason
          if (checkOutTimeParsed.isBefore(DateFormat('HH:mm').parse('12:00'))) {
            if (reason.trim().isEmpty) {
              _errorMessage = 'Reason is required for early check-out.';
              notifyListeners();
              return;
            }
          }

          // Check-out after 2:00 PM is invalid
          if (checkOutTimeParsed.isAfter(DateFormat('HH:mm').parse('14:00'))) {
            _errorMessage =
                'First shift check-out is no longer allowed after 2:00 PM.';
            notifyListeners();
            return;
          }
        } else if (_shiftType == 'secondShift') {
          final checkOutTimeParsed = DateFormat('HH:mm').parse(checkOutTime);

          // Check-out before 5:00 PM requires reason
          if (checkOutTimeParsed.isBefore(DateFormat('HH:mm').parse('17:00'))) {
            if (reason.trim().isEmpty) {
              _errorMessage = 'Reason is required for early check-out.';
              notifyListeners();
              return;
            }
          }
        }
      }

      // Validate shift type for check-in/out
      String shift =
          (_shiftType == 'firstShift') ? 'firstShift' : 'secondShift';

      Map<String, dynamic> requestBody = {
        "userId": userId,
        "shift": shift,
        "checkInTime": checkInTime,
        "checkOutTime": checkOutTime,
        "reason": reason,
      };

      // print("Sending request: $requestBody");

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
