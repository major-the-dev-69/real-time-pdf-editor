class ProjectSiteModel {
  final String uuid;
  final String projectId;
  final String projectTitle;
  final String name;
  final String code;
  final String description;
  final bool status;
  final String createdAt;
  final String updatedAt;

  ProjectSiteModel({
    required this.uuid,
    this.projectId = '',
    this.projectTitle = '',
    required this.name,
    required this.code,
    required this.description,
    this.status = true,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory ProjectSiteModel.fromJson(Map<String, dynamic> json) {
    String projId = '';
    String projTitle = '';
    final projectObj = json['project'];
    if (projectObj != null && projectObj is Map) {
      projId = projectObj['uuid']?.toString() ?? projectObj['id']?.toString() ?? '';
      projTitle = projectObj['title']?.toString() ?? projectObj['name']?.toString() ?? '';
    } else {
      projId = json['projectId']?.toString() ?? json['project_id']?.toString() ?? '';
      projTitle = json['projectTitle']?.toString() ?? '';
    }

    final rawStatus = json['status'];
    bool statusBool = true;
    if (rawStatus is bool) {
      statusBool = rawStatus;
    } else if (rawStatus != null) {
      statusBool = rawStatus.toString().toLowerCase() == 'true' || rawStatus.toString() == '1';
    }

    return ProjectSiteModel(
      uuid: json['uuid']?.toString() ?? json['id']?.toString() ?? '',
      projectId: projId,
      projectTitle: projTitle,
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: statusBool,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'name': name,
      'code': code,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
