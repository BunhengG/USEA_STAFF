class AttendanceItem {
  final int id;
  final String userId;
  final String username;
  final DateTime date;
  final DateTime? firstShiftCheckIn;
  final DateTime? firstShiftCheckOut;
  final DateTime? secondShiftCheckIn;
  final DateTime? secondShiftCheckOut;
  final String attendStatus;

  AttendanceItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.date,
    this.firstShiftCheckIn,
    this.firstShiftCheckOut,
    this.secondShiftCheckIn,
    this.secondShiftCheckOut,
    required this.attendStatus,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      date: DateTime.parse(json['date']),
      firstShiftCheckIn: json['firstShiftCheckIn'] != null
          ? DateTime.parse(json['firstShiftCheckIn'])
          : null,
      firstShiftCheckOut: json['firstShiftCheckOut'] != null
          ? DateTime.parse(json['firstShiftCheckOut'])
          : null,
      secondShiftCheckIn: json['secondShiftCheckIn'] != null
          ? DateTime.parse(json['secondShiftCheckIn'])
          : null,
      secondShiftCheckOut: json['secondShiftCheckOut'] != null
          ? DateTime.parse(json['secondShiftCheckOut'])
          : null,
      attendStatus: json['attendStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'date': date.toIso8601String(),
      'firstShiftCheckIn': firstShiftCheckIn?.toIso8601String(),
      'firstShiftCheckOut': firstShiftCheckOut?.toIso8601String(),
      'secondShiftCheckIn': secondShiftCheckIn?.toIso8601String(),
      'secondShiftCheckOut': secondShiftCheckOut?.toIso8601String(),
      'attendStatus': attendStatus,
    };
  }
}

List<AttendanceItem> attendanceItemFromJson(List<dynamic> jsonList) {
  return jsonList.map((json) => AttendanceItem.fromJson(json)).toList();
}

List<Map<String, dynamic>> attendanceItemToJson(List<AttendanceItem> items) {
  return items.map((item) => item.toJson()).toList();
}
