class UserModel {
  final int? id;
  final String uuid;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final bool status;
  final String createdAt;

  UserModel({
    this.id,
    this.uuid = '',
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    this.status = true,
    this.createdAt = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    bool statusBool = true;
    if (rawStatus is bool) {
      statusBool = rawStatus;
    } else if (rawStatus != null) {
      statusBool = rawStatus.toString().toLowerCase() == 'true' ||
          rawStatus.toString() == '1';
    }

    int? parsedId;
    if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString());
    }

    return UserModel(
      id: parsedId,
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      role: json['role']?.toString() ?? 'admin',
      status: statusBool,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'status': status,
      if (createdAt.isNotEmpty) 'created_at': createdAt,
    };
  }

  Map<String, dynamic> toCreateJson(String password) {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'role': role,
    };
  }

  Map<String, dynamic> toUpdateJson({String? password}) {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'status': status,
      if (password != null && password.isNotEmpty) 'password': password,
    };
  }
}

class PaginationModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;
  final bool hasMorePages;

  PaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.from = 0,
    this.to = 0,
    this.hasMorePages = false,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '10') ?? 10,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      from: int.tryParse(json['from']?.toString() ?? '0') ?? 0,
      to: int.tryParse(json['to']?.toString() ?? '0') ?? 0,
      hasMorePages: json['has_more_pages'] == true,
    );
  }
}
