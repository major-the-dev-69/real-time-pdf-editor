import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../../dashboard/model/real_estate_project_model.dart';

class ProjectListController extends GetxController {
  final projects = <RealEstateProject>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  int currentPage = 1;
  int lastPage = 1;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchProjects(refresh: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        currentPage < lastPage) {
      loadMore();
    }
  }

  Future<void> fetchProjects({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      isLoading.value = true;
    }

    try {
      final response = await Get.find<ApiServices>().callGetApi(
        ApiConstants.projects,
        queryParameters: {'page': currentPage},
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final data = response.data;
        final rawProjects = data['projects'];
        final pagination = data['pagination'];

        if (pagination != null && pagination is Map) {
          currentPage =
              (pagination['current_page'] as num?)?.toInt() ?? currentPage;
          lastPage = (pagination['last_page'] as num?)?.toInt() ?? lastPage;
        }

        List<RealEstateProject> fetchedList = [];
        if (rawProjects is List) {
          fetchedList = rawProjects
              .map(
                (item) =>
                    RealEstateProject.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }

        if (refresh) {
          projects.assignAll(fetchedList);
        } else {
          projects.addAll(fetchedList);
        }
      } else {
        if (refresh) {
          projects.clear();
        }
        CustomSnackBar.showError(message: response.message);
      }
    } catch (e) {
      printMessage("⚠️ Error fetching projects: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (currentPage >= lastPage || isLoadingMore.value) return;
    isLoadingMore.value = true;
    currentPage++;
    await fetchProjects(refresh: false);
  }

  Future<void> deleteProject(String uuid) async {
    if (uuid.isEmpty) return;

    final response = await Get.find<ApiServices>().callDeleteApi(
      '${ApiConstants.projects}/$uuid',
      isUserRequired: true,
    );

    if (response.status) {
      projects.removeWhere((p) => p.id == uuid);
      CustomSnackBar.showSuccess(message: response.message);
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }
}
