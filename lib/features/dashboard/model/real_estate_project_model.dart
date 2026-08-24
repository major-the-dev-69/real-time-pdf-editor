const List<String> globalPropertyImages = [
  'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=1935&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=2075&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=2053&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=1974&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=2069&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1592595896551-12b371d546d5?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1503387762-592deb58ef4e?q=80&w=2071&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b7?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1512915922686-57c11dde9b6b?q=80&w=2073&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1600565193348-f74bd3c7ccdf?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1600573472591-ee6b68d14c68?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1575517111478-7f6afd0973db?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?q=80&w=2065&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=2070&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1493809842364-78817add7ffb?q=80&w=2070&auto=format&fit=crop',
];

String getPropertyImageFallback(String? rawUrl, String idOrTitle) {
  if (rawUrl != null &&
      rawUrl.trim().isNotEmpty &&
      rawUrl.trim().toLowerCase() != 'null') {
    return rawUrl.trim();
  }
  final hash = idOrTitle.hashCode.abs();
  return globalPropertyImages[hash % globalPropertyImages.length];
}

class RealEstateProject {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final int siteCount;
  final int pdfCount;
  final String status;
  final String builderName;
  final String description;

  const RealEstateProject({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.siteCount,
    required this.pdfCount,
    required this.status,
    this.builderName = '',
    this.description = '',
  });

  factory RealEstateProject.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    String statusStr = 'Active';
    if (rawStatus is bool) {
      statusStr = rawStatus ? 'Active' : 'Inactive';
    } else if (rawStatus != null) {
      statusStr = rawStatus.toString();
    }

    final idStr = json['uuid']?.toString() ?? json['id']?.toString() ?? '';
    final titleStr = json['title']?.toString() ?? '';
    final rawImage = json['image']?.toString() ?? json['imageUrl']?.toString();
    final finalImageUrl = getPropertyImageFallback(
      rawImage,
      idStr.isNotEmpty ? idStr : titleStr,
    );

    return RealEstateProject(
      id: idStr,
      title: titleStr,
      location: json['location']?.toString() ?? '',
      imageUrl: finalImageUrl,
      siteCount: json['site_count'] ?? 0,
      pdfCount: json['pdf_count'] ?? 0,
      status: statusStr,
      builderName:
          json['builder_name']?.toString() ??
          json['builderName']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': id,
      'title': title,
      'location': location,
      'image': imageUrl,
      'status': status == 'Active',
      'builder_name': builderName,
      'description': description,
    };
  }
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

  factory SiteName.fromJson(Map<String, dynamic> json) {
    return SiteName(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      projectId:
          json['projectId']?.toString() ?? json['project_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      pdfCount: json['pdfCount'] ?? json['pdf_count'] ?? 0,
    );
  }
}
