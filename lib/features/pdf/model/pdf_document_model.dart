import '../../../core/helper/date_formatter_helper.dart';

class PdfDocumentModel {
  final String id;
  final String title;
  final String projectId;
  final String projectName;
  final String siteId;
  final String siteName;
  final String fileSize;
  final String updatedAt;
  final String createdAt;
  final int pageCount;
  final String pdfUrl;
  final String description;
  final List<String> sharedAvatars;
  final String category;
  final String originalName;
  final String fileName;
  final bool status;

  String get formattedDate => DateFormatterHelper.formatIsoDate(
        updatedAt.isNotEmpty ? updatedAt : createdAt,
      );

  String get relativeDate => DateFormatterHelper.formatRelativeOrDate(
        updatedAt.isNotEmpty ? updatedAt : createdAt,
      );

  const PdfDocumentModel({
    required this.id,
    required this.title,
    required this.projectId,
    required this.projectName,
    required this.siteId,
    required this.siteName,
    required this.fileSize,
    required this.updatedAt,
    this.createdAt = '',
    required this.pageCount,
    required this.pdfUrl,
    required this.description,
    this.sharedAvatars = const [],
    required this.category,
    this.originalName = '',
    this.fileName = '',
    this.status = true,
  });

  factory PdfDocumentModel.fromJson(Map<String, dynamic> json) {
    String projId = '';
    String projName = '';
    final projectObj = json['project'];
    if (projectObj != null && projectObj is Map) {
      projId = projectObj['uuid']?.toString() ?? projectObj['id']?.toString() ?? '';
      projName = projectObj['title']?.toString() ?? projectObj['name']?.toString() ?? '';
    } else {
      projId = json['projectId']?.toString() ?? json['project_id']?.toString() ?? '';
      projName = json['projectName']?.toString() ?? '';
    }

    String sId = '';
    String sName = '';
    final siteObj = json['site'];
    if (siteObj != null && siteObj is Map) {
      sId = siteObj['uuid']?.toString() ?? siteObj['id']?.toString() ?? '';
      sName = siteObj['name']?.toString() ?? siteObj['title']?.toString() ?? '';
    } else {
      sId = json['siteId']?.toString() ?? json['site_id']?.toString() ?? '';
      sName = json['siteName']?.toString() ?? '';
    }

    final rawSize = json['file_size'] ?? json['fileSize'];
    String formattedSize = '0 KB';
    if (rawSize is num) {
      formattedSize = _formatBytes(rawSize.toInt());
    } else if (rawSize != null) {
      formattedSize = rawSize.toString();
    }

    final rawStatus = json['status'];
    bool statusBool = true;
    if (rawStatus is bool) {
      statusBool = rawStatus;
    } else if (rawStatus != null) {
      statusBool = rawStatus.toString() == '1' || rawStatus.toString().toLowerCase() == 'true';
    }

    return PdfDocumentModel(
      id: json['uuid']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      projectId: projId,
      projectName: projName,
      siteId: sId,
      siteName: sName,
      fileSize: formattedSize,
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      pageCount: (json['page_count'] as num?)?.toInt() ?? json['pageCount'] ?? 0,
      pdfUrl: json['file_url']?.toString() ?? json['pdfUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sharedAvatars: const [],
      category: json['category']?.toString() ?? '',
      originalName: json['original_name']?.toString() ?? json['originalName']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? json['fileName']?.toString() ?? '',
      status: statusBool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'title': title,
      'project': {'uuid': projectId, 'title': projectName},
      'site': {'uuid': siteId, 'name': siteName},
      'file_size': fileSize,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'page_count': pageCount,
      'file_url': pdfUrl,
      'description': description,
      'category': category,
      'original_name': originalName,
      'file_name': fileName,
      'status': status,
    };
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toDouble() <= 0) ? 0 : (bytes.toString().length - 1) ~/ 3;
    if (i >= suffixes.length) i = suffixes.length - 1;
    double num = bytes / (1 << (i * 10));
    return "${num.toStringAsFixed(1)} ${suffixes[i]}";
  }
}
