class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final bool status;
  final String lastLogin;
  final String createdAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    required this.status,
    required this.lastLogin,
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] == true || json['status'] == 1,
      lastLogin: json['last_login'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
