class PdfDocumentModel {
  final String id;
  final String title;
  final String projectId;
  final String projectName;
  final String siteId;
  final String siteName;
  final String fileSize;
  final String updatedAt;
  final int pageCount;
  final String pdfUrl;
  final String description;
  final List<String> sharedAvatars;
  final String category;

  const PdfDocumentModel({
    required this.id,
    required this.title,
    required this.projectId,
    required this.projectName,
    required this.siteId,
    required this.siteName,
    required this.fileSize,
    required this.updatedAt,
    required this.pageCount,
    required this.pdfUrl,
    required this.description,
    required this.sharedAvatars,
    required this.category,
  });
}
