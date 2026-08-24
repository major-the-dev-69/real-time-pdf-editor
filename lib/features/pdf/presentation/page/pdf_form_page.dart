import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sai_associates/app/app_routes.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_dropdown.dart';
import '../../../../widgets/custom_text_field.dart';
import '../controller/pdf_form_controller.dart';

class PdfFormPage extends GetView<PdfFormController> {
  const PdfFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditMode.value
                ? 'Edit PDF Document'
                : 'Upload New PDF',
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(AppAssets.backArrow),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project & Site Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Project Dropdown
                Obx(() {
                  final projects = controller.projectsList;
                  final selectedId = controller.selectedProjectId.value;
                  final isLoading = controller.isLoadingProjects.value;

                  final validValue = projects.any((p) => p.id == selectedId)
                      ? selectedId
                      : null;

                  return CustomDropdown<String>(
                    value: validValue,
                    labelText: 'Project *',
                    hintText: isLoading
                        ? 'Loading Projects...'
                        : 'Select Project',
                    prefixIcon: Icons.business_rounded,
                    isLoading: isLoading,
                    items: projects.map((proj) {
                      return DropdownMenuItem<String>(
                        value: proj.id,
                        child: Text(
                          proj.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select a project';
                      }
                      return null;
                    },
                    onChanged: controller.onProjectChanged,
                    onAddPressed: () async {
                      final result = await Get.toNamed(AppRoutes.addProject);
                      if (result != null && result as bool) {
                        controller.fetchProjects();
                      }
                    },
                  );
                }),

                const SizedBox(height: 16),

                // Site Dropdown
                Obx(() {
                  final sites = controller.sitesList;
                  final selectedId = controller.selectedSiteId.value;
                  final isLoading = controller.isLoadingSites.value;
                  final hasProject =
                      controller.selectedProjectId.value.isNotEmpty;

                  final validValue = sites.any((s) => s.uuid == selectedId)
                      ? selectedId
                      : null;

                  String hintStr = 'Select Site';
                  if (!hasProject) {
                    hintStr = 'Select Project First';
                  } else if (isLoading) {
                    hintStr = 'Loading Sites...';
                  } else if (sites.isEmpty) {
                    hintStr = 'No Sites Available';
                  }

                  return CustomDropdown<String>(
                    value: validValue,
                    labelText: 'Site *',
                    hintText: hintStr,
                    prefixIcon: AppAssets.icSiteMap,
                    isLoading: isLoading,
                    items: sites.map((site) {
                      return DropdownMenuItem<String>(
                        value: site.uuid,
                        child: Text(
                          site.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select a site';
                      }
                      return null;
                    },
                    onChanged: hasProject ? controller.onSiteChanged : null,
                    onAddPressed: () async {
                      final result = await Get.toNamed(AppRoutes.addSite);
                      if (result != null && result as bool) {
                        controller.fetchSites(
                          controller.selectedProjectId.value,
                        );
                      }
                    },
                  );
                }),

                const SizedBox(height: 24),

                Text(
                  'Document Metadata',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.titleController,
                  labelText: 'Document Title *',
                  hintText: 'e.g. Master Site Plan 2026',
                  prefixIcon: AppAssets.icPdf,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter document title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.categoryController,
                  labelText: 'Category *',
                  hintText: 'e.g. Site Plan, Billing, Layout',
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: 'Description',
                  hintText: 'e.g. Master layout annotations & site details...',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  'File Attachment',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final file = controller.selectedFile.value;
                  return InkWell(
                    onTap: controller.pickPdfFile,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: file != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                          width: file != null ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              AppAssets.icPdf,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file != null
                                      ? file.path.split('/').last
                                      : (controller.isEditMode.value
                                            ? 'Change PDF File (Optional)'
                                            : 'Select PDF File *'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  file != null
                                      ? '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB'
                                      : 'Tap to browse document files',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (file != null)
                            IconButton(
                              icon: const Icon(
                                AppAssets.icCloseCircle,
                                size: 20,
                              ),
                              onPressed: controller.clearSelectedFile,
                            )
                          else
                            Icon(
                              Icons.upload_file_rounded,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Document Status',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.status.value ? 'Active' : 'Inactive',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: controller.status.value
                                    ? Colors.green
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: controller.status.value,
                          onChanged: controller.toggleStatus,
                          activeTrackColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => CustomButton(
                    title: controller.isEditMode.value
                        ? 'Update PDF'
                        : 'Upload PDF',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.submitPdf,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
