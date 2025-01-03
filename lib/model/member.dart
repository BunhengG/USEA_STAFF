class MemberItem {
  final int id;
  final String name;
  final String position;
  final String department;
  final String company;
  final String phoneNumber;
  final String phoneNumberService;

  MemberItem({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.company,
    required this.phoneNumber,
    required this.phoneNumberService,
  });

  factory MemberItem.fromJson(Map<String, dynamic> json) {
    return MemberItem(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      department: json['department'],
      company: json['company'],
      phoneNumber: json['phoneNumber'],
      phoneNumberService: json['phoneNumberService'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'company': company,
      'phoneNumber': phoneNumber,
      'phoneNumberService': phoneNumberService,
    };
  }
}

List<MemberItem> memberItemFromJson(List<dynamic> jsonList) {
  return jsonList.map((json) => MemberItem.fromJson(json)).toList();
}

List<Map<String, dynamic>> memberItemToJson(List<MemberItem> items) {
  return items.map((item) => item.toJson()).toList();
}
