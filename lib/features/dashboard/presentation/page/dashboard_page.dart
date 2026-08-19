import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../db/shared_pref_manager.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/pdf_list_item.dart';
import '../widgets/project_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final userRole = SharedPrefManager().userRoleEnum;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          final projects = controller.projectsList;
          final availableSites = controller.availableSites;
          final filteredPdfs = controller.filteredPdfs;
          final selectedProjId = controller.selectedProjectId.value;
          final selectedSiteId = controller.selectedSiteId.value;

          return CustomScrollView(
            slivers: [
              // Pinned AppBar at Top
              SliverAppBar(
                pinned: true,
                floating: true,
                elevation: 2,
                shadowColor: theme.shadowColor.withValues(alpha: 0.1),
                backgroundColor: theme.scaffoldBackgroundColor,
                expandedHeight: 125.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting & Notification Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PBD Group Real Estate',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Projects & Site PDFs',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.profile);
                                    },
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(AppAssets.icNotification),
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.notifications);
                                    },
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar permanently pinned inside AppBar bottom
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    color: theme.scaffoldBackgroundColor,
                    child: TextField(
                      onChanged: controller.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search site name, project or PDF...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        prefixIcon: const Icon(AppAssets.icSearch, size: 20),
                        suffixIcon: controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  AppAssets.icCloseCircle,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    controller.updateSearchQuery(''),
                              )
                            : const Icon(AppAssets.icFilterTag, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Real Estate Projects Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 4, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Real Estate Projects',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(AppRoutes.myProjectList);
                              },
                              borderRadius: BorderRadius.circular(8),
                              splashColor: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              highlightColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Text(
                                  'View All',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (userRole.canCreateProject) ...[
                            const SizedBox(width: 4),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.addProject);
                                },
                                customBorder: const CircleBorder(),
                                splashColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                                highlightColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Real Estate Project Cards Carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 175,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: projects.length + 1,
                    itemBuilder: (context, index) {
                      if (index == projects.length) {
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.myProjectList);
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'View All',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final project = projects[index];
                      return ProjectCard(
                        project: project,
                        isSelected: selectedProjId == project.id,
                        onTap: () => controller.selectProject(
                          selectedProjId == project.id ? 'all' : project.id,
                        ),
                        onEdit: userRole.canEditProject
                            ? () {
                                Get.toNamed(
                                  AppRoutes.editProject,
                                  arguments: project.toJson(),
                                );
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ),

              // Filter by Sites Chips Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 6),
                  child: Row(
                    children: [
                      Text(
                        'Filter by Site Name',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${availableSites.length} Sites',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (selectedProjId != 'all')
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.siteList,
                                arguments: {'projectId': selectedProjId},
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            splashColor: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            highlightColor: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Text(
                                'Manage Sites',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Site Filter Chips Row
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      FilterChip(
                        selected: selectedSiteId == 'all',
                        label: const Text('All Sites'),
                        onSelected: (selected) => controller.selectSite('all'),
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: selectedSiteId == 'all'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: selectedSiteId == 'all'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.15,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...availableSites.map((site) {
                        final isSelected = selectedSiteId == site.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(site.name),
                            onSelected: (selected) => controller.selectSite(
                              isSelected ? 'all' : site.id,
                            ),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHigh,
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.15,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Site PDFs Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 6),
                  child: Row(
                    children: [
                      Text(
                        'Site Documents & PDFs',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${filteredPdfs.length} Docs',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (userRole.canUploadPdf)
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              final result = await Get.toNamed(
                                AppRoutes.addPdf,
                                arguments: {
                                  'siteId': selectedSiteId != 'all'
                                      ? selectedSiteId
                                      : '',
                                  'projectId': selectedProjId != 'all'
                                      ? selectedProjId
                                      : '',
                                },
                              );
                              if (result == true && selectedSiteId != 'all') {
                                controller.fetchPdfsForSite(selectedSiteId);
                              }
                            },
                            customBorder: const CircleBorder(),
                            splashColor: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            highlightColor: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add_circle_outline_rounded,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Filtered PDF Documents List
              if (filteredPdfs.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          AppAssets.icPdfFile,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Site PDFs Found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try selecting a different project or site filter.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.clearFilters,
                          icon: const Icon(AppAssets.icCloseCircle, size: 16),
                          label: const Text('Reset Filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final pdf = filteredPdfs[index];
                      return PdfListItem(
                        pdf: pdf,
                        onTap: () {
                          Get.toNamed(AppRoutes.pdfDetail, arguments: pdf);
                        },
                      );
                    }, childCount: filteredPdfs.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        }),
      ),
    );
  }
}
