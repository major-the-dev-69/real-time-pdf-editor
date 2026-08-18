class SiteRequestModel {
  final String name;
  final String code;
  final String description;
  final bool status;

  SiteRequestModel({
    required this.name,
    required this.code,
    required this.description,
    this.status = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'status': status,
    };
  }

  factory SiteRequestModel.fromJson(Map<String, dynamic> json) {
    return SiteRequestModel(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? true,
    );
  }
}
