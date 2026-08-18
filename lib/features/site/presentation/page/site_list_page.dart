import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../model/project_site_model.dart';
import '../controller/site_list_controller.dart';

class SiteListPage extends GetView<SiteListController> {
  const SiteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final userRole = SharedPrefManager().userRoleEnum;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.projectTitle.value.isNotEmpty
                ? '${controller.projectTitle.value} Sites'
                : 'Project Sites',
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(AppAssets.backArrow),
        ),
        actions: [
          if (userRole.canCreateSite)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: theme.colorScheme.primary,
                size: 26,
              ),
              tooltip: 'Add Site',
              onPressed: () async {
                final result = await Get.toNamed(
                  AppRoutes.addSite,
                  arguments: {'projectId': controller.projectId.value},
                );
                if (result == true) {
                  controller.fetchSites();
                }
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Project Filter Chips Bar
            Obx(() {
              final projects = controller.projectsList;
              if (projects.isEmpty) return const SizedBox.shrink();

              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final proj = projects[index];
                    final isSelected = controller.projectId.value == proj.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(proj.title),
                        avatar: Icon(
                          AppAssets.icProjectBuilding,
                          size: 16,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                        ),
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectProjectFilter(proj);
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            }),

            // Sites List Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.sites.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppAssets.icSiteMap,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Sites Available',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap refresh or add a new site for this project.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => controller.fetchSites(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchSites(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.sites.length,
                    itemBuilder: (context, index) {
                      final site = controller.sites[index];
                      return _buildSiteCard(context, site, userRole);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteCard(
    BuildContext context,
    ProjectSiteModel site,
    UserRole userRole,
  ) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      AppAssets.icSiteMap,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        site.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (site.code.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    site.code,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (site.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              site.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            height: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: site.status
                          ? Colors.green
                          : theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    site.status ? 'Active' : 'Inactive',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: site.status
                          ? Colors.green
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (userRole.canEditSite)
                    IconButton(
                      icon: const Icon(AppAssets.icEditPen, size: 18),
                      color: theme.colorScheme.primary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        final result = await Get.toNamed(
                          AppRoutes.editSite,
                          arguments: {
                            'projectId': controller.projectId.value,
                            'site': site,
                          },
                        );
                        if (result == true) {
                          controller.fetchSites();
                        }
                      },
                    ),
                  if (userRole.canDeleteSite)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showDeleteConfirmation(context, site),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProjectSiteModel site) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Site'),
        content: Text(
          'Are you sure you want to delete "${site.name}"? This action cannot be undone.',
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
              controller.deleteSite(site.uuid);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
