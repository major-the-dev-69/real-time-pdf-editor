import '../../../core/helper/date_formatter_helper.dart';

class PdfProjectModel {
  final String uuid;
  final String title;

  const PdfProjectModel({this.uuid = '', this.title = ''});

  factory PdfProjectModel.fromJson(Map<String, dynamic> json) {
    return PdfProjectModel(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'uuid': uuid, 'title': title};
}

class PdfSiteModel {
  final String uuid;
  final String name;
  final String code;

  const PdfSiteModel({this.uuid = '', this.name = '', this.code = ''});

  factory PdfSiteModel.fromJson(Map<String, dynamic> json) {
    return PdfSiteModel(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'uuid': uuid, 'name': name, 'code': code};
}

class PdfDocumentModel {
  final String uuid;
  final PdfProjectModel? project;
  final PdfSiteModel? site;
  final String title;
  final String originalName;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String fileType;
  final int pageCount;
  final String mimeType;
  final String category;
  final String description;
  final bool status;
  final String createdAt;
  final String updatedAt;

  const PdfDocumentModel({
    required this.uuid,
    this.project,
    this.site,
    required this.title,
    this.originalName = '',
    this.fileName = '',
    required this.fileUrl,
    this.fileSize = 0,
    this.fileType = '',
    this.pageCount = 0,
    this.mimeType = '',
    this.category = '',
    this.description = '',
    this.status = true,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory PdfDocumentModel.fromJson(Map<String, dynamic> json) {
    return PdfDocumentModel(
      uuid: json['uuid'] ?? '',
      project: json['project'] != null
          ? PdfProjectModel.fromJson(json['project'])
          : null,
      site: json['site'] != null ? PdfSiteModel.fromJson(json['site']) : null,
      title: json['title'] ?? '',
      originalName: json['original_name'] ?? '',
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileSize: json['file_size'] ?? 0,
      fileType: json['file_type'] ?? '',
      pageCount: json['page_count'] ?? 0,
      mimeType: json['mime_type'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'project': project?.toJson(),
    'site': site?.toJson(),
    'title': title,
    'original_name': originalName,
    'file_name': fileName,
    'file_url': fileUrl,
    'file_size': fileSize,
    'file_type': fileType,
    'page_count': pageCount,
    'mime_type': mimeType,
    'category': category,
    'description': description,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  // Helper Getters
  String get id => uuid;
  String get pdfUrl => fileUrl;
  String get projectId => project?.uuid ?? '';
  String get projectName => project?.title ?? '';
  String get siteId => site?.uuid ?? '';
  String get siteName => site?.name ?? '';
  String get siteCode => site?.code ?? '';

  String get formattedFileSize => _formatBytes(fileSize);

  String get formattedDate => DateFormatterHelper.formatIsoDate(
    updatedAt.isNotEmpty ? updatedAt : createdAt,
  );

  String get relativeDate => DateFormatterHelper.formatRelativeOrDate(
    updatedAt.isNotEmpty ? updatedAt : createdAt,
  );

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toDouble() <= 0) ? 0 : (bytes.toString().length - 1) ~/ 3;
    if (i >= suffixes.length) i = suffixes.length - 1;
    double num = bytes / (1 << (i * 10));
    return "${num.toStringAsFixed(1)} ${suffixes[i]}";
  }
}
