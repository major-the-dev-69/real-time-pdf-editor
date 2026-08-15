class RealEstateProject {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final int siteCount;
  final int pdfCount;
  final String status;
  final List<SiteName> sites;

  const RealEstateProject({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.siteCount,
    required this.pdfCount,
    required this.status,
    required this.sites,
  });
}

class SiteName {
  final String id;
  final String projectId;
  final String name;
  final String code;
  final int pdfCount;

  const SiteName({
    required this.id,
    required this.projectId,
    required this.name,
    required this.code,
    required this.pdfCount,
  });
}
