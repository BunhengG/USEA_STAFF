// class UserItem {
//   int id;
//   String username;
//   String password;
//   String name;
//   String userId;
//   String gender;
//   DateTime? dob;
//   String position;
//   DateTime? joinAt;
//   DateTime? endProbation;
//   DateTime? workAnniversary;

//   UserItem({
//     required this.id,
//     required this.username,
//     required this.password,
//     required this.name,
//     required this.userId,
//     required this.gender,
//     this.dob,
//     required this.position,
//     this.joinAt,
//     this.endProbation,
//     this.workAnniversary,
//   });

//   // Factory method to create UserItem from a Map
//   factory UserItem.fromMap(Map<String, dynamic> map) {
//     return UserItem(
//       id: map['id'], // Now it correctly parses id as an integer
//       username: map['username'] ?? 'Anonymous',
//       password: map['password'] ?? 'blank',
//       name: map['name'] ?? 'Unnamed',
//       userId: map['userId'] ?? '',
//       gender: map['gender'] ?? 'No Gender',
//       dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
//       position: map['position'] ?? 'No Position',
//       joinAt: map['joinAt'] != null ? DateTime.parse(map['joinAt']) : null,
//       endProbation: map['endProbation'] != null
//           ? DateTime.parse(map['endProbation'])
//           : null,
//       workAnniversary: map['workAnniversary'] != null
//           ? DateTime.parse(map['workAnniversary'])
//           : null,
//     );
//   }

//   // Method to convert the object to a Map for sending to an API or storage
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'username': username,
//       'password': password,
//       'name': name,
//       'userId': userId,
//       'gender': gender,
//       'dob': dob?.toIso8601String(),
//       'position': position,
//       'joinAt': joinAt?.toIso8601String(),
//       'endProbation': endProbation?.toIso8601String(),
//       'workAnniversary': workAnniversary?.toIso8601String(),
//     };
//   }
// }
class UserItem {
  int id; // Updated to int as per the backend API response
  String username;
  String password;
  String name;
  String userId;
  String gender;
  DateTime? dob;
  String position;
  DateTime? joinAt;
  DateTime? endProbation;
  DateTime? workAnniversary;

  UserItem({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.userId,
    required this.gender,
    this.dob,
    required this.position,
    this.joinAt,
    this.endProbation,
    this.workAnniversary,
  });

  /// Factory method to create UserItem from JSON
  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Anonymous',
      password: json['password'] ?? 'blank',
      name: json['name'] ?? 'Unnamed',
      userId: json['userId'] ?? '',
      gender: json['gender'] ?? 'No Gender',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      position: json['position'] ?? 'No Position',
      joinAt: json['joinAt'] != null ? DateTime.tryParse(json['joinAt']) : null,
      endProbation: json['endProbation'] != null
          ? DateTime.tryParse(json['endProbation'])
          : null,
      workAnniversary: json['workAnniversary'] != null
          ? DateTime.tryParse(json['workAnniversary'])
          : null,
    );
  }

  /// Convert UserItem to a Map for sending to API or storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'userId': userId,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'position': position,
      'joinAt': joinAt?.toIso8601String(),
      'endProbation': endProbation?.toIso8601String(),
      'workAnniversary': workAnniversary?.toIso8601String(),
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
