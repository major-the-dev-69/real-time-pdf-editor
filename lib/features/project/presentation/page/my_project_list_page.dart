import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../model/real_estate_project_model.dart';
import '../../../dashboard/presentation/widgets/project_card.dart';
import '../controller/project_detail_controller.dart';
import '../controller/project_list_controller.dart';

class MyProjectListPage extends GetView<ProjectListController> {
  const MyProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final userRole = SharedPrefManager().userRoleEnum;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Projects'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(AppAssets.backArrow),
        ),
        actions: [
          if (userRole.canCreateProject)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: theme.colorScheme.primary,
                size: 26,
              ),
              tooltip: 'Add Project',
              onPressed: () async {
                final result = await Get.toNamed(AppRoutes.addProject);
                if (result == true) {
                  controller.fetchProjects(refresh: true);
                }
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppAssets.icProjectBuilding,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Projects Found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap refresh or add a new project.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchProjects(refresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchProjects(refresh: true),
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(20),
              itemCount:
                  controller.projects.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.projects.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final project = controller.projects[index];
                return ProjectCard(
                  project: project,
                  isVertical: true,
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.projectDetails,
                      arguments: {ProjectArguments.project: project},
                    );
                  },
                  onEdit: userRole.canEditProject
                      ? () async {
                          final result = await Get.toNamed(
                            AppRoutes.editProject,
                            arguments: project.toJson(),
                          );
                          if (result == true) {
                            controller.fetchProjects(refresh: true);
                          }
                        }
                      : null,
                  onDelete: userRole.canDeleteProject
                      ? () => _showDeleteConfirmation(context, project)
                      : null,
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    RealEstateProject project,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.colorScheme.error,
              foregroundColor: context.theme.colorScheme.onError,
            ),
            onPressed: () {
              Get.back();
              controller.deleteProject(project.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
