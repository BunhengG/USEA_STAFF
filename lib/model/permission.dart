class PermissionItem {
  final int id;
  final String userId;
  final String username;
  final int permissions;
  final DateTime date;
  final int permissionDay;
  final String reason;

  PermissionItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.date,
    required this.permissions,
    required this.permissionDay,
    required this.reason,
  });

  factory PermissionItem.fromJson(Map<String, dynamic> json) {
    return PermissionItem(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      date: DateTime.parse(json['date']),
      permissions: json['permissions'],
      permissionDay: json['permissionDay'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'date': date.toIso8601String(),
      'permissions': permissions,
      'permissionDay': permissionDay,
      'reason': reason,
    };
  }
}

List<PermissionItem> permissionItemFromJson(List<dynamic> jsonList) {
  return jsonList.map((json) => PermissionItem.fromJson(json)).toList();
}

List<Map<String, dynamic>> permissionItemToJson(List<PermissionItem> items) {
  return items.map((item) => item.toJson()).toList();
}
