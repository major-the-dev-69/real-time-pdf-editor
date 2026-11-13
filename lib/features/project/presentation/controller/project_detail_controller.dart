import 'package:get/get.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../pdf/model/pdf_document_model.dart';
import '../../model/real_estate_project_model.dart';

class ProjectArguments {
  static const String project = 'project';
}

class ProjectDetailController extends GetxController {
  late final RealEstateProject project;

  final allSites = <SiteName>[].obs;
  final allPdfs = <PdfDocumentModel>[].obs;
  final selectedSiteId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      project = Get.arguments[ProjectArguments.project] as RealEstateProject;
      fetchSitesForProject(project.id);
    } else {
      printMessage("⚠️ Project not passed in arguments");
    }
  }

  List<SiteName> get availableSites => allSites;

  List<PdfDocumentModel> get filteredPdfs => allPdfs;

  Future<void> fetchSitesForProject(String projId) async {
    if (projId.isEmpty) return;

    allSites.clear();
    allPdfs.clear();
    selectedSiteId.value = '';

    try {
      final endpoint = '${ApiConstants.projects}/$projId/sites';
      final response = await Get.find<ApiServices>().callGetApi(
        endpoint,
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final data = response.data;
        final rawSites = data['sites'];
        if (rawSites is List) {
          final parsedSites = rawSites
              .map((s) => SiteName.fromJson(s as Map<String, dynamic>))
              .toList();

          allSites.assignAll(parsedSites);

          if (parsedSites.isNotEmpty) {
            selectSite(parsedSites.first.id);
          }
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching sites for project $projId: $e");
    }
  }

  Future<void> fetchPdfsForSite(String siteId) async {
    if (siteId.isEmpty) return;

    try {
      final endpoint = 'sites/$siteId/pdfs';
      final response = await Get.find<ApiServices>().callGetApi(
        endpoint,
        queryParameters: {'page': 1, 'per_page': 20},
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final data = response.data;
        final rawPdfs = data['pdfs'];
        if (rawPdfs is List) {
          final fetchedPdfs = rawPdfs
              .map((p) => PdfDocumentModel.fromJson(p as Map<String, dynamic>))
              .toList();

          allPdfs.assignAll(fetchedPdfs);
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching PDFs for site $siteId: $e");
    }
  }

  void selectSite(String id) {
    if (selectedSiteId.value == id || id.isEmpty) return;
    selectedSiteId.value = id;
    fetchPdfsForSite(id);
  }
}
