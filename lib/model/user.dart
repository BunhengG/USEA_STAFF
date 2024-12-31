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

  // Factory method to create UserItem from a Map
  factory UserItem.fromMap(Map<String, dynamic> map) {
    return UserItem(
      id: map['id'], // Now it correctly parses id as an integer
      username: map['username'] ?? 'Anonymous',
      password: map['password'] ?? 'blank',
      name: map['name'] ?? 'Unnamed',
      userId: map['userId'] ?? '',
      gender: map['gender'] ?? 'No Gender',
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
      position: map['position'] ?? 'No Position',
      joinAt: map['joinAt'] != null ? DateTime.parse(map['joinAt']) : null,
      endProbation: map['endProbation'] != null
          ? DateTime.parse(map['endProbation'])
          : null,
      workAnniversary: map['workAnniversary'] != null
          ? DateTime.parse(map['workAnniversary'])
          : null,
    );
  }

  // Method to convert the object to a Map for sending to an API or storage
  Map<String, dynamic> toMap() {
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
