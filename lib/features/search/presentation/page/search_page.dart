import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sai_associates/app/app_routes.dart';
import 'package:sai_associates/core/utils/app_assets.dart';

import '../controller/search_page_controller.dart';
import '../../model/search_result_model.dart';

class SearchPage extends GetView<SearchPageController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(AppAssets.backArrow),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Hero(
            tag: 'dashboard_search_bar',
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: controller.searchBarController,
                autofocus: true,
                onChanged: controller.onSearchQueryChanged,
                decoration: InputDecoration(
                  hintText: 'Search site name, project or PDF...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(AppAssets.icSearch, size: 20),
                  suffixIcon: Obx(() {
                    if (controller.isLoading.value) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    }
                    if (controller.searchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(
                          AppAssets.icCloseCircle,
                          size: 18,
                        ),
                        onPressed: controller.clearSearch,
                      );
                    }
                    return const Icon(AppAssets.icFilterTag, size: 18);
                  }),
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
      ),
      body: SafeArea(
        child: Obx(() {
          final query = controller.searchQuery.value.trim();
          final result = controller.searchResult.value;

          if (query.isEmpty) {
            return _buildInitialSearchState(context);
          }

          if (controller.isLoading.value && result == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result == null || result.isEmpty) {
            return _buildNoResultsState(context, query);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sites Section
                if (result.sites.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    title: 'Sites',
                    count: result.sites.length,
                    icon: AppAssets.icLocationPin,
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.sites.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final site = result.sites[index];
                      return _buildSiteCard(context, site);
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Projects Section
                if (result.projects.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    title: 'Projects',
                    count: result.projects.length,
                    icon: AppAssets.icProjectBuilding,
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.projects.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final project = result.projects[index];
                      return _buildProjectCard(context, project);
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // PDFs Section
                if (result.pdfs.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    title: 'Site Documents & PDFs',
                    count: result.pdfs.length,
                    icon: AppAssets.icPdfFile,
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.pdfs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final pdf = result.pdfs[index];
                      return _buildPdfCard(context, pdf);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInitialSearchState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppAssets.icSearchNormal,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Search Projects, Sites & PDFs',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type a site name, project title or document name to search across the system.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, String query) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppAssets.icCloseCircle,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No projects, sites or PDFs matched "$query".\nTry checking for spelling or searching with a different term.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteCard(BuildContext context, SearchSiteItem site) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: ListTile(
        onTap: () {
          Get.toNamed(AppRoutes.siteList, arguments: {'siteId': site.uuid, 'search': site.name});
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            AppAssets.icLocationPin,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          site.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            if (site.code.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  site.code,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (site.projectTitle.isNotEmpty)
              Expanded(
                child: Text(
                  site.projectTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: const Icon(AppAssets.frontArrow, size: 18),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, SearchProjectItem project) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: ListTile(
        onTap: () {
          Get.toNamed(AppRoutes.myProjectList);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            AppAssets.icProjectBuilding,
            color: Colors.blue.shade700,
            size: 20,
          ),
        ),
        title: Text(
          project.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          project.location.isNotEmpty
              ? project.location
              : (project.builderName.isNotEmpty ? project.builderName : 'Project'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(AppAssets.frontArrow, size: 18),
      ),
    );
  }

  Widget _buildPdfCard(BuildContext context, SearchPdfItem pdf) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: ListTile(
        onTap: () {
          Get.toNamed(AppRoutes.pdfDetail, arguments: pdf.id);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            AppAssets.icPdfFile,
            color: Colors.red.shade700,
            size: 20,
          ),
        ),
        title: Text(
          pdf.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          pdf.siteName.isNotEmpty ? pdf.siteName : 'Document',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(AppAssets.frontArrow, size: 18),
      ),
    );
  }
}
