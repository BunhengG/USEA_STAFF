// // BUG: Fixing

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:timezone/data/latest.dart';
// import 'package:timezone/timezone.dart' as tz;
// import '../helper/shared_pref_helper.dart';
// import '../utils/domain.dart';

// class CheckInOutProvider with ChangeNotifier {
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _shiftStatus;
//   String? _shiftType;

//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   String? get shiftStatus => _shiftStatus;
//   String? get shiftType => _shiftType;

//   final double fixedLatitude = 13.350918350149795;
//   final double fixedLongitude = 103.86433962916841;
//   final double allowedRange = 50.0;

//   late tz.Location phnomPenh;

//   CheckInOutProvider() {
//     initializeTimeZones();
//     phnomPenh = tz.getLocation('Asia/Phnom_Penh');
//   }

//   void setShiftStatus(String status) {
//     _shiftStatus = status;
//     notifyListeners();
//   }

//   Future<void> updateButtonState(String currentTime, String userId) async {
//     if (userId.isEmpty) {
//       _setErrorMessage('User ID is empty. Please log in again.');
//       return;
//     }

//     _setLoadingState(true);
//     final currentDate = _getFormattedDate();
//     final encodedUserId = Uri.encodeComponent(userId);
//     final url =
//         Uri.parse('${ApiEndpoints.getShifts}$encodedUserId/$currentDate');

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         _processShiftData(jsonDecode(response.body));
//       } else {
//         _setErrorMessage('Failed to fetch shift data.');
//       }
//     } catch (e) {
//       _setErrorMessage('Error: $e');
//     } finally {
//       _setLoadingState(false);
//     }
//   }

//   Future<void> checkInOut(String qrCode, {required String reason}) async {
//     if (!_isValidQRCode(qrCode)) {
//       _setErrorMessage('Invalid QR code format.');
//       return;
//     }

//     _setLoadingState(true);
//     try {
//       final userId = await SharedPrefHelper.getUserId();
//       if (userId == null) {
//         _setErrorMessage('User ID not found. Please log in again.');
//         return;
//       }

//       if (!await _isWithinAllowedRange()) {
//         _setErrorMessage('You are not within the allowed range for check-in.');
//         return;
//       }

//       if (_shiftStatus == 'checkOut' && !_isReasonValid(reason)) {
//         return;
//       }

//       final requestBody = _createRequestBody(userId, reason);
//       final response = await http.post(
//         Uri.parse(ApiEndpoints.getCheckInOut),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 201) {
//         _processCheckInOutResponse(jsonDecode(response.body));
//       } else {
//         _setErrorMessage('Error: ${response.body}');
//       }
//     } catch (e) {
//       _setErrorMessage('Error: $e');
//     } finally {
//       _setLoadingState(false);
//     }
//   }

//   bool get shouldShowCheckInReason => _isLateForShift();
//   bool get shouldShowCheckOutReason => _isEarlyForShiftEnd();

//   // Helper Methods
//   void _setLoadingState(bool isLoading) {
//     _isLoading = isLoading;
//     notifyListeners();
//   }

//   void _setErrorMessage(String message) {
//     _errorMessage = message;
//     notifyListeners();
//   }

//   String _getFormattedDate() {
//     final now = DateTime.now();
//     return DateFormat('dd MMMM yyyy').format(now);
//   }

//   bool _isValidQRCode(String qrCode) =>
//       qrCode.startsWith('usea') && qrCode.length >= 7;

//   Future<bool> _isWithinAllowedRange() async {
//     final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     final distance = Geolocator.distanceBetween(
//       position.latitude,
//       position.longitude,
//       fixedLatitude,
//       fixedLongitude,
//     );
//     return distance <= allowedRange;
//   }

//   bool _isLateForShift() {
//     final now = tz.TZDateTime.now(phnomPenh);
//     final firstShiftStart = _getShiftTime(hour: 7);
//     final secondShiftStart = _getShiftTime(hour: 14);

//     return now.isAfter(firstShiftStart) &&
//             now.isBefore(firstShiftStart.add(const Duration(hours: 5))) ||
//         now.isAfter(secondShiftStart) &&
//             now.isBefore(secondShiftStart.add(const Duration(hours: 3)));
//   }

//   bool _isEarlyForShiftEnd() {
//     final now = tz.TZDateTime.now(phnomPenh);
//     final firstShiftEnd = _getShiftTime(hour: 12);
//     final secondShiftEnd = _getShiftTime(hour: 17);

//     return now.isBefore(firstShiftEnd) || now.isBefore(secondShiftEnd);
//   }

//   bool _isReasonValid(String reason) {
//     if (reason.trim().isEmpty) {
//       _setErrorMessage('Reason is required for early check-out.');
//       return false;
//     }
//     return true;
//   }

//   Map<String, dynamic> _createRequestBody(String userId, String reason) {
//     final now = tz.TZDateTime.now(phnomPenh);
//     final time = DateFormat('HH:mm:ss').format(now);
//     final shift = (_shiftType == 'firstShift') ? 'firstShift' : 'secondShift';

//     return {
//       "userId": userId,
//       "shift": shift,
//       "checkInTime": time,
//       "checkOutTime": time,
//       "reason": reason,
//     };
//   }

//   tz.TZDateTime _getShiftTime({required int hour}) {
//     final now = tz.TZDateTime.now(phnomPenh);
//     return tz.TZDateTime(phnomPenh, now.year, now.month, now.day, hour, 0);
//   }

//   void _processShiftData(dynamic data) {
//     final shiftData = data[0];
//     final shiftRecord = shiftData['shiftRecord'];
//     _shiftType = shiftData['shift'];

//     final isToday = _getFormattedDate() == shiftData['date'];
//     if (!isToday || shiftRecord['firstShift']['checkIn'] == null) {
//       _shiftStatus = 'checkIn';
//     } else if (shiftRecord['firstShift']['checkOut'] == null ||
//         shiftRecord['secondShift']['checkIn'] == null ||
//         shiftRecord['secondShift']['checkOut'] == null) {
//       _shiftStatus = shiftRecord['firstShift']['checkOut'] == null
//           ? 'checkOut'
//           : 'checkIn';
//     } else {
//       _shiftStatus = 'disabled';
//     }

//     notifyListeners();
//   }

//   void _processCheckInOutResponse(dynamic data) {
//     final shiftRecord = data['shiftRecord'];

//     if (shiftRecord['firstShift']['checkIn'] != null &&
//         shiftRecord['firstShift']['checkOut'] != null &&
//         shiftRecord['secondShift']['checkIn'] == null) {
//       _shiftStatus = 'checkIn';
//     } else if (shiftRecord['secondShift']['checkOut'] == null) {
//       _shiftStatus = 'checkOut';
//     } else {
//       _shiftStatus = 'disabled';
//     }

//     notifyListeners();
//   }
// }

// BUG: Fixing

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
  // Constants
  static const double _fixedLatitude = 13.350918350149795;
  static const double _fixedLongitude = 103.86433962916841;
  static const double _allowedRange = 50.0;

  // Variables
  bool _isLoading = false;
  String? _errorMessage;
  String? _shiftStatus;
  late tz.Location _phnomPenh;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get shiftStatus => _shiftStatus;

  String get activeShiftInfo {
    if (_shiftStatus == 'checkIn') {
      if (_isFirstShift) return 'Check-In for First Shift';
      if (_isSecondShift) return 'Check-In for Second Shift';
    } else if (_shiftStatus == 'checkOut') {
      if (_isFirstShift) return 'Check-Out for First Shift';
      if (_isSecondShift) return 'Check-Out for Second Shift';
    }
    return 'No Active Shift';
  }

  // Constructor
  CheckInOutProvider() {
    initializeTimeZones();
    _phnomPenh = tz.getLocation('Asia/Phnom_Penh');
  }

  // Public Methods
  void setShiftStatus(String status) {
    _shiftStatus = status;
    notifyListeners();
  }

  Future<void> updateButtonState(String currentTime, String userId) async {
    if (userId.isEmpty) {
      _setError('User ID is empty. Please log in again.');
      return;
    }

    _setLoading(true);
    final currentDate = _formattedDate();
    final encodedUserId = Uri.encodeComponent(userId);
    final url =
        Uri.parse('${ApiEndpoints.getShifts}$encodedUserId/$currentDate');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _processShiftData(jsonDecode(response.body));
      } else {
        _setError('Failed to fetch shift data.');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _processShiftData(dynamic data) {
    final shiftData = data[0];
    final shiftRecord = shiftData['shiftRecord'];

    final isToday = _formattedDate() == shiftData['date'];
    if (!isToday || shiftRecord['firstShift']['checkIn'] == null) {
      _shiftStatus = 'checkIn';
    } else if (shiftRecord['firstShift']['checkOut'] == null) {
      _shiftStatus = 'checkOut';
    } else if (shiftRecord['secondShift']['checkIn'] == null) {
      _shiftStatus = 'checkIn';
    } else if (shiftRecord['secondShift']['checkOut'] == null) {
      _shiftStatus = 'checkOut';
    } else {
      _shiftStatus = 'disabled';
    }
    notifyListeners();
  }

  // NOTE: Check-in and Check-out
  Future<void> checkInOut(String qrCode, {required String reason}) async {
    if (!_isValidQRCode(qrCode)) {
      _setError('Invalid QR code format.');
      return;
    }

    _setLoading(true);
    try {
      final userId = await SharedPrefHelper.getUserId();
      if (userId == null) {
        _setError('User ID not found. Please log in again.');
        return;
      }

      if (!await _isWithinAllowedRange()) {
        _setError('You are not within the allowed range for check-in.');
        return;
      }

      if (_shiftStatus == 'checkOut' && !_isReasonValid(reason)) {
        return;
      }

      final requestBody = _createRequestBody(userId, reason);
      final response = await http.post(
        Uri.parse(ApiEndpoints.getCheckInOut),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        _processCheckInOutResponse(jsonDecode(response.body));
      } else {
        _setError('Error: ${response.body}');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // COMMENT: BELOW method are [_isValidQRCode, _isWithinAllowedRange, _isReasonValid, _createRequestBody, _processCheckInOutResponse]
  // Helper Methods
  String _formattedDate() => DateFormat('dd MMMM yyyy').format(DateTime.now());

  bool _isValidQRCode(String qrCode) =>
      qrCode.startsWith('usea') && qrCode.length >= 7;

  Future<bool> _isWithinAllowedRange() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _fixedLatitude,
      _fixedLongitude,
    );
    return distance <= _allowedRange;
  }

  bool _isReasonValid(String reason) {
    if (reason.trim().isEmpty) {
      _setError('Reason is required for early check-out.');
      return false;
    }
    return true;
  }

  Map<String, dynamic> _createRequestBody(String userId, String reason) {
    final now = tz.TZDateTime.now(_phnomPenh);
    final time = DateFormat('HH:mm:ss').format(now);

    return {
      "userId": userId,
      "reason": reason.isNotEmpty ? reason : "On-time",
      if (_shiftStatus == 'checkIn') "checkInTime": time,
      if (_shiftStatus == 'checkOut') "checkOutTime": time,
    };
  }

  void _processCheckInOutResponse(dynamic data) {
    final shiftRecord = data['shiftRecord'];

    if (shiftRecord['firstShift']['checkIn'] == null) {
      _shiftStatus = 'checkIn';
    } else if (shiftRecord['firstShift']['checkOut'] == null) {
      _shiftStatus = 'checkOut';
    } else if (shiftRecord['secondShift']['checkIn'] == null) {
      _shiftStatus = 'checkIn';
    } else if (shiftRecord['secondShift']['checkOut'] == null) {
      _shiftStatus = 'checkOut';
    } else {
      _shiftStatus = 'disabled';
    }
    notifyListeners();
  }

  // COMMENT: When modal should show check-in and check-out reason
  bool get shouldShowCheckInReason => _isLateForShift();
  bool get shouldShowCheckOutReason => _isEarlyForShiftEnd();

  // Time and Shift Helpers
  bool get _isFirstShift => _isWithinShiftTime(7, 5);
  bool get _isSecondShift => _isWithinShiftTime(14, 3);

  bool _isLateForShift() => _isFirstShift || _isSecondShift;
  bool _isEarlyForShiftEnd() => _isBeforeShiftEnd(12) || _isBeforeShiftEnd(17);

  bool _isWithinShiftTime(int startHour, int durationHours) {
    final now = tz.TZDateTime.now(_phnomPenh);
    final shiftStart = _shiftTime(startHour);
    return now.isAfter(shiftStart) &&
        now.isBefore(shiftStart.add(Duration(hours: durationHours)));
  }

  bool _isBeforeShiftEnd(int endHour) {
    final now = tz.TZDateTime.now(_phnomPenh);
    final shiftEnd = _shiftTime(endHour);
    return now.isBefore(shiftEnd);
  }

  tz.TZDateTime _shiftTime(int hour) {
    final now = tz.TZDateTime.now(_phnomPenh);
    return tz.TZDateTime(_phnomPenh, now.year, now.month, now.day, hour);
  }

  // COMMENT: loading and error state
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
