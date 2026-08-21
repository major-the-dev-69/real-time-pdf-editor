import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../../core/enums/user_role.dart';
import '../controller/pdf_detail_controller.dart';

class PdfDetailPage extends GetView<PdfDetailController> {
  const PdfDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = SharedPrefManager().userRoleEnum;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PDF Details'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(AppAssets.backArrow),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (userRole.canUploadPdf)
            IconButton(
              icon: const Icon(AppAssets.icEditPen),
              tooltip: 'Edit PDF',
              onPressed: () async {
                final pdf = controller.pdfDocument.value;
                if (pdf != null) {
                  final result = await Get.toNamed(
                    AppRoutes.editPdf,
                    arguments: {'pdf': pdf},
                  );
                  if (result == true) {
                    controller.fetchPdfDetails(pdf.id);
                  }
                }
              },
            ),
          if (userRole.canDeleteProject)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: theme.colorScheme.error,
              tooltip: 'Delete PDF',
              onPressed: () {
                final pdf = controller.pdfDocument.value;
                if (pdf != null) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Delete PDF'),
                      content: Text(
                        'Are you sure you want to delete "${pdf.title}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: Get.back,
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          ),
                          onPressed: () {
                            Get.back();
                            controller.deletePdf(pdf.id);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          IconButton(
            icon: const Icon(AppAssets.icSharePdf),
            onPressed: controller.sharePdf,
            tooltip: 'Share Document',
          ),
        ],
      ),
      body: Obx(() {
        final pdf = controller.pdfDocument.value;
        if (pdf == null) {
          return const Center(child: Text('No PDF Document selected'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Document Card / Mock Viewer Preview Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.surfaceContainerHighest,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppAssets.icPdf,
                        size: 52,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pdf.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pdf.category,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Project & Site Context Info Card
              Text(
                'Real Estate Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      icon: AppAssets.icProjectBuilding,
                      label: 'Project Name',
                      value: pdf.projectName,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      context,
                      icon: AppAssets.icSiteMap,
                      label: 'Site Name / Sector',
                      value: pdf.siteName,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      context,
                      icon: AppAssets.icDocumentDetail,
                      label: 'Pages Count',
                      value: '${pdf.pageCount} Pages',
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      context,
                      icon: AppAssets.icCalendar,
                      label: 'Last Updated',
                      value: pdf.formattedDate,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      context,
                      icon: AppAssets.icPdfFile,
                      label: 'File Size',
                      value: pdf.fileSize,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Overview Description Section
              Text(
                'Description & Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  pdf.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Open & Edit PDF Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.pdfOpen, arguments: pdf);
                  },
                  icon: const Icon(AppAssets.icEyeView, size: 22),
                  label: Text(
                    SharedPrefManager().userRoleEnum.canDraw
                        ? 'Open & Edit PDF Document'
                        : 'Open & View PDF Document',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Open NextGen PDF Editor (Test) Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.nextGenPdfOpen, arguments: pdf);
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 22),
                  label: const Text(
                    'Open NextGen PDF Editor (Test)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.sharePdf,
                      icon: const Icon(AppAssets.icSharePdf, size: 20),
                      label: const Text('Share PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isDownloading.value
                          ? null
                          : controller.downloadPdf,
                      icon: controller.isDownloading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(AppAssets.icDownloadPdf, size: 20),
                      label: Text(
                        controller.isDownloading.value
                            ? 'Downloading...'
                            : 'Download PDF',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.mediaQueryPadding.bottom),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
