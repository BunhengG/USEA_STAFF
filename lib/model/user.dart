class UserItem {
  int id; // Updated to int as per the backend API response
  String username;
  String password;
  String name;
  String image;
  String userId;
  String gender;
  DateTime? dob;
  String position;
  String joinAt;
  String endProbation;
  String workAnniversary;

  UserItem({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.image,
    required this.userId,
    required this.gender,
    this.dob,
    required this.position,
    required this.joinAt,
    required this.endProbation,
    required this.workAnniversary,
  });

  /// Factory method to create UserItem from JSON
  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Anonymous',
      password: json['password'] ?? 'blank',
      name: json['name'] ?? 'Unnamed',
      image: json['image'] ?? 'No Image',
      userId: json['userId'] ?? '',
      gender: json['gender'] ?? 'No Gender',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      position: json['position'] ?? 'No Position',
      joinAt: json['joinAt'],
      endProbation: json['endProbation'],
      workAnniversary: json['workAnniversary'],
    );
  }

  /// Convert UserItem to a Map for sending to API or storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'image': image,
      'userId': userId,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'position': position,
      'joinAt': joinAt,
      'endProbation': endProbation,
      'workAnniversary': workAnniversary,
    };
  }
}

/// Parse JSON list to List<UserItem>
List<UserItem> attendanceItemFromJson(List<dynamic> jsonList) {
  return jsonList.map((json) => UserItem.fromJson(json)).toList();
}

/// Convert List<UserItem> to JSON List
List<Map<String, dynamic>> attendanceItemToJson(List<UserItem> items) {
  return items.map((item) => item.toJson()).toList();
}
