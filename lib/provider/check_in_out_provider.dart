import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../helper/shared_pref_helper.dart';
import '../utils/domain.dart';

class CheckInOutProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _checkOutTime;

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
  void setShiftStatus(String status, {String? additionalData}) {
    _shiftStatus = status;

    print('Setting shift status: $_shiftStatus');

    if (additionalData != null) {
      print('Additional Data: $additionalData');
    }
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

  //? Checking if check-in is late
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

//! Updating ======================
  bool get shouldShowFirstShiftCheckOutReason {
    tz.TZDateTime currentTime = tz.TZDateTime.now(phnomPenh);

    tz.TZDateTime noon = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 12, 0); // 12:00 PM

    // Show reason if check-out is after 12:00 PM (late check-out)
    if (currentTime.isAfter(noon)) {
      print('First shift check-out is after 12:00 PM, reason is required.');
      return true;
    }

    print('First shift check-out does not require a reason.');
    return false;
  }

  bool get shouldShowSecondShiftCheckOutReason {
    tz.TZDateTime currentTime = tz.TZDateTime.now(phnomPenh);

    tz.TZDateTime evening = tz.TZDateTime(phnomPenh, currentTime.year,
        currentTime.month, currentTime.day, 17, 0); // 05:00 PM

    // Show reason if check-out is after 5:00 PM (late check-out)
    if (currentTime.isAfter(evening)) {
      print('Second shift check-out is after 5:00 PM, reason is required.');
      return true;
    }

    print('Second shift check-out does not require a reason.');
    return false;
  }

  bool get shouldShowCheckOutReason {
    final isSecondShiftCheckOutAfter5 = shouldShowSecondShiftCheckOutReason &&
        _checkOutTime == null &&
        DateFormat('HH:mm')
            .parse(_checkOutTime!)
            .isAfter(DateFormat('HH:mm').parse('17:00'));

    return shouldShowFirstShiftCheckOutReason || isSecondShiftCheckOutAfter5;
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
        position.latitude,
        position.longitude,
        fixedLatitude,
        fixedLongitude,
      );

      if (distanceInMeters > allowedRange) {
        _errorMessage = 'You are not within the allowed range for check-in.';
        notifyListeners();
        return;
      }

      // Fetch shift data
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

        // Prioritize first shift check-out
        if (firstShift['checkIn'] != null && firstShift['checkOut'] == null) {
          _shiftType = 'firstShift'; // Checkout for first shift
          print('You are checking out for the first shift.');
        } else if (firstShift['checkIn'] != null &&
            firstShift['checkOut'] != null) {
          // First shift completed, now allow check-in for second shift
          if (secondShift['checkIn'] == null) {
            _shiftType = 'secondShift'; // Checking in for second shift
            print('You are checking in for the second shift.');
          } else if (secondShift['checkIn'] != null &&
              secondShift['checkOut'] == null) {
            _shiftType = 'secondShift'; // Checking out for second shift
            print('You are checking out for the second shift.');
          } else {
            _shiftType = 'disabled';
            _errorMessage =
                'All shifts are either completed or not yet checked in.';
            notifyListeners();
            return;
          }
        } else {
          _shiftType = 'disabled';
          _errorMessage =
              'All shifts are either completed or not yet checked in.';
          notifyListeners();
          return;
        }
      } else {
        _errorMessage = 'Failed to fetch shift data.';
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

      var postResponse = await http.post(
        Uri.parse(ApiEndpoints.getCheckInOut),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (postResponse.statusCode == 201) {
        _errorMessage = null;

        // Parse the response body to get shift data
        final data = jsonDecode(postResponse.body);

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
          if (data['shiftRecord']['firstShift']['checkOut'] == null) {
            shiftStatus = 'checkOut';
          } else {
            shiftStatus = 'disabled';
          }
        }

        _shiftStatus = shiftStatus;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error occurred during check-in/out: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  //* Helper function to load time zones
  Future<void> initializeTimeZones() async {
    tz.initializeTimeZones();
  }
}
