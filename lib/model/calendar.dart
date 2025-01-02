class CalendarItem {
  final int id;
  final String userId;
  final String username;
  final DateTime date;
  final String morningTime;
  final String afternoonTime;
  final String attendStatus;

  CalendarItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.date,
    required this.morningTime,
    required this.afternoonTime,
    required this.attendStatus,
  });

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    return CalendarItem(
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

List<CalendarItem> CalendarItemFromJson(List<dynamic> jsonList) {
  return jsonList.map((json) => CalendarItem.fromJson(json)).toList();
}

List<Map<String, dynamic>> CalendarItemToJson(List<CalendarItem> items) {
  return items.map((item) => item.toJson()).toList();
}
