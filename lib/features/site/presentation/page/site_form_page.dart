import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_dropdown.dart';
import '../../../../widgets/custom_text_field.dart';
import 'package:sai_associates/app/app_routes.dart';
import '../controller/site_form_controller.dart';

class SiteFormPage extends GetView<SiteFormController> {
  const SiteFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () =>
              Text(controller.isEditMode.value ? 'Edit Site' : 'Add New Site'),
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
                  'Site Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final projects = controller.projectsList;
                  final selectedId = controller.projectId.value;
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
                CustomTextField(
                  controller: controller.nameController,
                  labelText: 'Site Name *',
                  hintText: 'e.g. Master Layout',
                  prefixIcon: AppAssets.icSiteMap,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter site name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.codeController,
                  labelText: 'Site Code *',
                  hintText: 'e.g. ML-001',
                  prefixIcon: Icons.qr_code_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter site code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: 'Description',
                  hintText: 'e.g. Main township master layout & details...',
                  maxLines: 3,
                ),
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
                              'Site Status',
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
                        ? 'Update Site'
                        : 'Add Site',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.submitSite,
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
