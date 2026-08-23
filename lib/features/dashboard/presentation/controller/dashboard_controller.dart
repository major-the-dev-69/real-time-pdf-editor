import 'package:get/get.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../pdf/model/pdf_document_model.dart';
import '../../../profile/model/user_profile_model.dart';
import '../../model/real_estate_project_model.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  // Profile & Role State
  final userProfile = Rxn<UserProfileModel>();
  final userRole = ''.obs;

  // Real Estate Projects List
  final projectsList = <RealEstateProject>[].obs;

  // All PDF Documents
  final allPdfs = <PdfDocumentModel>[].obs;

  // Filter States
  final selectedProjectId = 'all'.obs;
  final selectedSiteId = 'all'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    userRole.value = SharedPrefManager().userRole;
    fetchProfile();
    fetchProjects();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await Get.find<ApiServices>().callGetApi(
        ApiConstants.profile,
        isUserRequired: true,
      );
      if (response.status && response.data != null) {
        final data = response.data;
        String? role;
        if (data is Map<String, dynamic>) {
          if (data['user'] != null && data['user'] is Map<String, dynamic>) {
            userProfile.value = UserProfileModel.fromJson(
              data['user'] as Map<String, dynamic>,
            );
            role = userProfile.value?.role;
          } else if (data['role'] != null) {
            role = data['role'].toString();
          }
        }
        if (role != null && role.isNotEmpty) {
          await SharedPrefManager().saveRole(role);
          userRole.value = role;
          printMessage(
            "✅ Profile fetched in DashboardController. Role updated in SharedPrefs: $role",
          );
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching profile in DashboardController: $e");
    }
  }

  Future<void> fetchProjects() async {
    try {
      final response = await Get.find<ApiServices>().callGetApi(
        ApiConstants.projects,
        isUserRequired: true,
      );
      if (response.status && response.data != null) {
        final data = response.data;
        final rawProjects = data['projects'];
        if (rawProjects is List) {
          final fetched = rawProjects
              .map((e) => RealEstateProject.fromJson(e as Map<String, dynamic>))
              .toList();
          projectsList.assignAll(fetched);
          if (fetched.isNotEmpty) {
            fetchSitesForProject(projectsList.first.id);
          }
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching projects in DashboardController: $e");
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // Get available sites based on selected project
  List<SiteName> get availableSites {
    if (selectedProjectId.value == 'all') {
      return projectsList.expand((proj) => proj.sites).toList();
    }
    final index = projectsList.indexWhere(
      (p) => p.id == selectedProjectId.value,
    );
    if (index != -1) {
      return projectsList[index].sites;
    }
    return [];
  }

  // Filtered PDFs computed property
  List<PdfDocumentModel> get filteredPdfs {
    return allPdfs.where((pdf) {
      // Project Filter
      if (selectedProjectId.value != 'all' &&
          pdf.projectId != selectedProjectId.value) {
        return false;
      }
      // Site Filter
      if (selectedSiteId.value != 'all' && pdf.siteId != selectedSiteId.value) {
        return false;
      }
      // Search Query Filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.toLowerCase().trim();
        final matchesTitle = pdf.title.toLowerCase().contains(query);
        final matchesProject = pdf.projectName.toLowerCase().contains(query);
        final matchesSite = pdf.siteName.toLowerCase().contains(query);
        final matchesCategory = pdf.category.toLowerCase().contains(query);
        return matchesTitle || matchesProject || matchesSite || matchesCategory;
      }
      return true;
    }).toList();
  }

  Future<void> fetchSitesForProject(String projId) async {
    if (projId == 'all' || projId.isEmpty) return;

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

          final index = projectsList.indexWhere((p) => p.id == projId);
          if (index != -1) {
            final old = projectsList[index];
            projectsList[index] = RealEstateProject(
              id: old.id,
              title: old.title,
              location: old.location,
              imageUrl: old.imageUrl,
              siteCount: parsedSites.length,
              pdfCount: old.pdfCount,
              status: old.status,
              builderName: old.builderName,
              description: old.description,
              sites: parsedSites,
            );
          }
          if (parsedSites.isNotEmpty) {
            fetchPdfsForSite(parsedSites.first.id);
          }
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching sites for project $projId: $e");
    }
  }

  Future<void> fetchPdfsForSite(String siteId) async {
    if (siteId == 'all' || siteId.isEmpty) return;

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

          final remaining = allPdfs
              .where((pdf) => pdf.siteId != siteId)
              .toList();
          allPdfs.assignAll([...fetchedPdfs, ...remaining]);
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching PDFs for site $siteId: $e");
    }
  }

  void selectProject(String id) {
    if (selectedProjectId.value == id) return;
    selectedProjectId.value = id;
    selectedSiteId.value = 'all'; // Reset site selection on project change
    if (id != 'all') {
      fetchSitesForProject(id);
    }
  }

  void selectSite(String id) {
    selectedSiteId.value = id;
    if (id != 'all') {
      fetchPdfsForSite(id);
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearFilters() {
    selectedProjectId.value = 'all';
    selectedSiteId.value = 'all';
    searchQuery.value = '';
  }
}
