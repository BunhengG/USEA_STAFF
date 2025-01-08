class AttendanceItem {
  final String userId;
  final String name;
  final String shift;
  final String date;
  final ShiftRecord shiftRecord;

  AttendanceItem({
    required this.userId,
    required this.name,
    required this.shift,
    required this.date,
    required this.shiftRecord,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      userId: json['userId'] ?? 'Unknown',
      name: json['name'] ?? 'Unknown',
      shift: json['shift'] ?? 'Unknown',
      date: json['date'] ?? 'Unknown',
      shiftRecord: ShiftRecord.fromJson(json['shiftRecord'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'shift': shift,
      'date': date,
      'shiftRecord': shiftRecord.toJson(),
    };
  }
}

// Represents the entire shift record containing firstShift and secondShift
class ShiftRecord {
  final ShiftDetails firstShift;
  final ShiftDetails secondShift;

  ShiftRecord({
    required this.firstShift,
    required this.secondShift,
  });

  factory ShiftRecord.fromJson(Map<String, dynamic> json) {
    return ShiftRecord(
      firstShift: ShiftDetails.fromJson(json['firstShift'] ?? {}),
      secondShift: ShiftDetails.fromJson(json['secondShift'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstShift': firstShift.toJson(),
      'secondShift': secondShift.toJson(),
    };
  }
}

// Represents checkIn and checkOut details for a single shift
class ShiftDetails {
  final ShiftTimeDetails checkIn;
  final ShiftTimeDetails checkOut;

  ShiftDetails({
    required this.checkIn,
    required this.checkOut,
  });

  factory ShiftDetails.fromJson(Map<String, dynamic> json) {
    return ShiftDetails(
      checkIn: ShiftTimeDetails.fromJson(json['checkIn'] ?? {}),
      checkOut: ShiftTimeDetails.fromJson(json['checkOut'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn.toJson(),
      'checkOut': checkOut.toJson(),
    };
  }
}

// Represents time, status, and reason for checkIn and checkOut
class ShiftTimeDetails {
  final String time;
  final String status;
  final String reason;

  ShiftTimeDetails({
    required this.time,
    required this.status,
    required this.reason,
  });

  factory ShiftTimeDetails.fromJson(Map<String, dynamic> json) {
    return ShiftTimeDetails(
      time: json['time'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
      reason: json['reason'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'status': status,
      'reason': reason,
    };
  }
}
