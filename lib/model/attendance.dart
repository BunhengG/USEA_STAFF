class AttendanceItem {
  final int id;
  final String userId;
  final String username;
  final DateTime date;
  final String morningTime;
  final String afternoonTime;
  final String attendStatus;

  AttendanceItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.date,
    required this.morningTime,
    required this.afternoonTime,
    required this.attendStatus,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      date: DateTime.parse(json['date']),
      morningTime: json['morningTime'],
      afternoonTime: json['afternoonTime'],
      attendStatus: json['attendStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'date': date.toIso8601String(),
      'morningTime': morningTime,
      'afternoonTime': afternoonTime,
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
