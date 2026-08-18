import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/pdf_list_item.dart';
import '../widgets/project_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
                expandedHeight: 140.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                                    color: theme.colorScheme.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.person_outline_rounded),
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.profile);
                                    },
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHigh,
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            AppAssets.icProjectBuilding,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Real Estate Projects',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (selectedProjId != 'all' || selectedSiteId != 'all')
                        TextButton.icon(
                          onPressed: controller.clearFilters,
                          icon: const Icon(AppAssets.icCloseCircle, size: 16),
                          label: const Text('Clear Filters'),
                        ),
                    ],
                  ),
                ),
              ),

              // Horizontal Real Estate Project Cards Carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectCard(
                        project: project,
                        isSelected: selectedProjId == project.id,
                        onTap: () => controller.selectProject(
                          selectedProjId == project.id ? 'all' : project.id,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Filter by Sites Chips Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      Icon(
                        AppAssets.icSiteMap,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
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
                          vertical: 2,
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
                        avatar: const Icon(AppAssets.icSiteMap, size: 16),
                        onSelected: (selected) => controller.selectSite('all'),
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
                            selectedColor: theme.colorScheme.primaryContainer,
                            checkmarkColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
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
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            AppAssets.icPdf,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Site Documents & PDFs',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${filteredPdfs.length} Documents',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
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
