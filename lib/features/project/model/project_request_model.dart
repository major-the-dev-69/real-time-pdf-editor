class ProjectRequestModel {
  final String title;
  final String builderName;
  final String description;
  final String location;
  final bool status;

  ProjectRequestModel({
    required this.title,
    required this.builderName,
    required this.description,
    required this.location,
    this.status = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'builder_name': builderName,
      'description': description,
      'location': location,
      'status': status,
    };
  }

  factory ProjectRequestModel.fromJson(Map<String, dynamic> json) {
    return ProjectRequestModel(
      title: json['title'] ?? '',
      builderName: json['builder_name'] ?? json['builderName'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? true,
    );
  }
}
