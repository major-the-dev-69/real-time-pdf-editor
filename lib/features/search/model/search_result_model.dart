class SearchResultModel {
  final List<SearchProjectItem> projects;
  final List<SearchSiteItem> sites;
  final List<SearchPdfItem> pdfs;

  SearchResultModel({
    required this.projects,
    required this.sites,
    required this.pdfs,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    List<SearchProjectItem> projectList = [];
    if (json['projects'] is List) {
      projectList = (json['projects'] as List)
          .map((e) => SearchProjectItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<SearchSiteItem> siteList = [];
    if (json['sites'] is List) {
      siteList = (json['sites'] as List)
          .map((e) => SearchSiteItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<SearchPdfItem> pdfList = [];
    if (json['pdfs'] is List) {
      pdfList = (json['pdfs'] as List)
          .map((e) => SearchPdfItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return SearchResultModel(
      projects: projectList,
      sites: siteList,
      pdfs: pdfList,
    );
  }

  bool get isEmpty => projects.isEmpty && sites.isEmpty && pdfs.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class SearchSiteItem {
  final String uuid;
  final String name;
  final String code;
  final String projectTitle;

  SearchSiteItem({
    required this.uuid,
    required this.name,
    required this.code,
    required this.projectTitle,
  });

  factory SearchSiteItem.fromJson(Map<String, dynamic> json) {
    String projTitle = '';
    final project = json['project'];
    if (project is Map) {
      final rawTitle = project['title'] ?? project['name'];
      if (rawTitle != null && rawTitle.toString().toLowerCase() != 'null') {
        projTitle = rawTitle.toString();
      }
    }

    final rawName = json['name'] ?? json['title'];
    final nameStr = (rawName != null && rawName.toString().toLowerCase() != 'null')
        ? rawName.toString()
        : '';

    final rawCode = json['code'];
    final codeStr = (rawCode != null && rawCode.toString().toLowerCase() != 'null')
        ? rawCode.toString()
        : '';

    final rawUuid = json['uuid'] ?? json['id'];
    final uuidStr = (rawUuid != null && rawUuid.toString().toLowerCase() != 'null')
        ? rawUuid.toString()
        : '';

    return SearchSiteItem(
      uuid: uuidStr,
      name: nameStr,
      code: codeStr,
      projectTitle: projTitle,
    );
  }
}

class SearchProjectItem {
  final String id;
  final String title;
  final String location;
  final String builderName;

  SearchProjectItem({
    required this.id,
    required this.title,
    required this.location,
    required this.builderName,
  });

  factory SearchProjectItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['uuid'] ?? json['id'];
    final idStr = (rawId != null && rawId.toString().toLowerCase() != 'null')
        ? rawId.toString()
        : '';

    final rawTitle = json['title'] ?? json['name'];
    final titleStr = (rawTitle != null && rawTitle.toString().toLowerCase() != 'null')
        ? rawTitle.toString()
        : '';

    final rawLoc = json['location'];
    final locStr = (rawLoc != null && rawLoc.toString().toLowerCase() != 'null')
        ? rawLoc.toString()
        : '';

    final rawBuilder = json['builder_name'] ?? json['builderName'];
    final builderStr = (rawBuilder != null && rawBuilder.toString().toLowerCase() != 'null')
        ? rawBuilder.toString()
        : '';

    return SearchProjectItem(
      id: idStr,
      title: titleStr,
      location: locStr,
      builderName: builderStr,
    );
  }
}

class SearchPdfItem {
  final String id;
  final String title;
  final String fileUrl;
  final String siteName;

  SearchPdfItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.siteName,
  });

  factory SearchPdfItem.fromJson(Map<String, dynamic> json) {
    String sName = '';
    final siteObj = json['site'];
    if (siteObj is Map) {
      final rawSName = siteObj['name'] ?? siteObj['title'];
      if (rawSName != null && rawSName.toString().toLowerCase() != 'null') {
        sName = rawSName.toString();
      }
    }
    if (sName.isEmpty && json['site_name'] != null && json['site_name'].toString().toLowerCase() != 'null') {
      sName = json['site_name'].toString();
    }

    final rawId = json['uuid'] ?? json['id'];
    final idStr = (rawId != null && rawId.toString().toLowerCase() != 'null')
        ? rawId.toString()
        : '';

    final rawTitle = json['title'] ?? json['name'];
    final titleStr = (rawTitle != null && rawTitle.toString().toLowerCase() != 'null')
        ? rawTitle.toString()
        : '';

    final rawUrl = json['file_url'] ?? json['pdf_url'];
    final urlStr = (rawUrl != null && rawUrl.toString().toLowerCase() != 'null')
        ? rawUrl.toString()
        : '';

    return SearchPdfItem(
      id: idStr,
      title: titleStr,
      fileUrl: urlStr,
      siteName: sName,
    );
  }
}
