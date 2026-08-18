import 'package:get/get.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../../dashboard/model/real_estate_project_model.dart';
import '../../model/project_site_model.dart';

class SiteListController extends GetxController {
  final sites = <ProjectSiteModel>[].obs;
  final projectsList = <RealEstateProject>[].obs;
  final isLoading = false.obs;

  final projectId = ''.obs;
  final projectTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkArguments();
    fetchProjectsList();
    if (projectId.value.isNotEmpty) {
      fetchSites();
    }
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args == null) return;

    if (args is String) {
      projectId.value = args;
    } else if (args is Map<String, dynamic>) {
      projectId.value =
          args['projectId']?.toString() ??
          args['id']?.toString() ??
          args['uuid']?.toString() ??
          '';
      projectTitle.value =
          args['projectTitle']?.toString() ?? args['title']?.toString() ?? '';
    }
  }

  Future<void> fetchProjectsList() async {
    try {
      final response = await Get.find<ApiServices>().callGetApi(
        ApiConstants.projects,
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final data = response.data;
        final rawProjects = data['projects'];
        if (rawProjects is List && rawProjects.isNotEmpty) {
          final fetched = rawProjects
              .map(
                (item) =>
                    RealEstateProject.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          projectsList.assignAll(fetched);

          if (projectId.value.isEmpty && fetched.isNotEmpty) {
            projectId.value = fetched.first.id;
            projectTitle.value = fetched.first.title;
            fetchSites();
          }
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching projects in SiteListController: $e");
    }
  }

  void selectProjectFilter(RealEstateProject proj) {
    if (projectId.value == proj.id) return;
    projectId.value = proj.id;
    projectTitle.value = proj.title;
    fetchSites();
  }

  Future<void> fetchSites() async {
    if (projectId.value.isEmpty) {
      printMessage("⚠️ Cannot fetch sites: projectId is empty");
      return;
    }

    isLoading.value = true;

    try {
      final endpoint = '${ApiConstants.projects}/${projectId.value}/sites';
      final response = await Get.find<ApiServices>().callGetApi(
        endpoint,
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final data = response.data;
        final rawSites = data['sites'];

        List<ProjectSiteModel> fetchedList = [];
        if (rawSites is List) {
          fetchedList = rawSites
              .map((e) => ProjectSiteModel.fromJson(e as Map<String, dynamic>))
              .toList();
          if (projectTitle.value.isEmpty && fetchedList.isNotEmpty) {
            projectTitle.value = fetchedList.first.projectTitle;
          }
        }
        sites.assignAll(fetchedList);
      } else {
        sites.clear();
        CustomSnackBar.showError(message: response.message);
      }
    } catch (e) {
      printMessage("⚠️ Error fetching sites: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSite(String siteUuid) async {
    if (siteUuid.isEmpty) return;

    final endpoint = '${ApiConstants.sites}/$siteUuid';
    final response = await Get.find<ApiServices>().callDeleteApi(
      endpoint,
      isUserRequired: true,
    );

    if (response.status) {
      sites.removeWhere((s) => s.uuid == siteUuid);
      CustomSnackBar.showSuccess(message: response.message);
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }
}
