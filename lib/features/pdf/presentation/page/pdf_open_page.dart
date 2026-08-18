import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../../core/enums/user_role.dart';
import '../controller/pdf_detail_controller.dart';
import '../widgets/annotation_painter.dart';

class PdfOpenPage extends GetView<PdfDetailController> {
  const PdfOpenPage({super.key});

  // Default sample PDF URL for testing if document URL is remote or placeholder
  static const String fallbackPdfUrl =
      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = SharedPrefManager().userRoleEnum;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final title = controller.pdfDocument.value?.title ?? 'PDF Document';
          return Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: false,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(AppAssets.backArrow),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Page Navigation Counter Indicator
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.currentPage.value} / ${controller.totalPages.value}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Action: Undo
          if (userRole.canUndo)
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              tooltip: 'Undo',
              onPressed: controller.undo,
            ),

          // Action: Clear All
          if (userRole.canClearAll)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear Annotations',
              onPressed: () {
                Get.defaultDialog(
                  title: 'Clear Annotations',
                  middleText:
                      'Are you sure you want to clear all drawing and text annotations?',
                  textConfirm: 'Clear All',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    controller.clearAllAnnotations();
                    Get.back();
                  },
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Mode Switcher Header Toolbar
          if (userRole.canDraw)
            _buildModeToolbar(context),

          // PDF Viewer Canvas & Interactive Annotation Layer Stack
          Expanded(
            child: Stack(
              children: [
                // Layer 1: Syncfusion PDF Viewer
                Obx(() {
                  return SfPdfViewer.network(
                    fallbackPdfUrl,
                    pageLayoutMode: PdfPageLayoutMode.single,
                    controller: controller.pdfViewerController,
                    //  canShowScrollHead: true,
                    //  canShowScrollStatus: true,
                    
                    enableDoubleTapZooming:
                        controller.activeMode.value == AnnotationMode.view,
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                      controller.totalPages.value =
                          details.document.pages.count;
                      controller.isLoaded.value = true;
                    },
                    onPageChanged: (PdfPageChangedDetails details) {
                      controller.currentPage.value = details.newPageNumber;
                    },
                  );
                }),

                // Layer 2: Interactive CustomPaint Annotation Layer
                Obx(() {
                  final mode = controller.activeMode.value;

                  return Positioned.fill(
                    child: IgnorePointer(
                      ignoring: mode == AnnotationMode.view,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          controller.startLine(details.localPosition);
                        },
                        onPanUpdate: (details) {
                          controller.updateLine(details.localPosition);
                        },
                        onPanEnd: (details) {
                          controller.endLine();
                        },
                        onTapUp: (details) {
                          if (mode == AnnotationMode.text) {
                            _showAddTextDialog(context, details.localPosition);
                          } else if (mode == AnnotationMode.erase) {
                            controller.eraseNear(details.localPosition);
                          }
                        },
                        child: CustomPaint(
                          painter: AnnotationPainter(
                            lines: controller.lines.toList(),
                            currentLine: controller.currentLine.value,
                            textAnnotations: controller.textAnnotations
                                .toList(),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  );
                }),

                // Layer 3: View Mode Active Indicator Banner
                Obx(() {
                  if (controller.activeMode.value == AnnotationMode.view) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    top: 12,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getModeIcon(controller.activeMode.value),
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _getModeInstruction(controller.activeMode.value),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Tool Control Panel (Color Palette & Stroke Slider)
          if (userRole.canDraw)
            Obx(() {
              if (controller.activeMode.value == AnnotationMode.view) {
                return const SizedBox.shrink();
              }
              return _buildBottomControlPanel(context);
            }),
        ],
      ),
    );
  }

  // Top Mode Selector Bar
  Widget _buildModeToolbar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Obx(() {
        final active = controller.activeMode.value;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModeButton(
                context,
                mode: AnnotationMode.view,
                label: 'Scroll/Pan',
                icon: Icons.back_hand_outlined,
                isSelected: active == AnnotationMode.view,
              ),
              const SizedBox(width: 6),
              _buildModeButton(
                context,
                mode: AnnotationMode.draw,
                label: 'Draw Stroke',
                icon: Icons.brush_rounded,
                isSelected: active == AnnotationMode.draw,
              ),
              const SizedBox(width: 6),
              _buildModeButton(
                context,
                mode: AnnotationMode.text,
                label: 'Add Text',
                icon: Icons.title_rounded,
                isSelected: active == AnnotationMode.text,
              ),
              const SizedBox(width: 6),
              _buildModeButton(
                context,
                mode: AnnotationMode.erase,
                label: 'Eraser',
                icon: Icons.cleaning_services_rounded,
                isSelected: active == AnnotationMode.erase,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required AnnotationMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => controller.setMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Control Panel: Color Picker & Stroke / Font Size Sliders
  Widget _buildBottomControlPanel(BuildContext context) {
    final theme = Theme.of(context);
    final mode = controller.activeMode.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color Selection Palette Row
          if (mode == AnnotationMode.draw || mode == AnnotationMode.text) ...[
            Row(
              children: [
                Text(
                  'Color:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.availableColors.map((color) {
                        return Obx(() {
                          final isSelected =
                              controller.selectedColor.value == color;
                          return GestureDetector(
                            onTap: () => controller.setColor(color),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(right: 10),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade400,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        });
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Stroke Width Slider (for Drawing mode)
          if (mode == AnnotationMode.draw)
            Row(
              children: [
                Text(
                  'Stroke Width:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => Slider(
                      value: controller.selectedStrokeWidth.value,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      label:
                          '${controller.selectedStrokeWidth.value.toInt()} px',
                      onChanged: controller.setStrokeWidth,
                    ),
                  ),
                ),
                Obx(
                  () => Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: controller.selectedStrokeWidth.value.clamp(
                        2.0,
                        20.0,
                      ),
                      height: controller.selectedStrokeWidth.value.clamp(
                        2.0,
                        20.0,
                      ),
                      decoration: BoxDecoration(
                        color: controller.selectedColor.value,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Font Size Slider (for Text mode)
          if (mode == AnnotationMode.text)
            Row(
              children: [
                Text(
                  'Font Size:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => Slider(
                      value: controller.selectedFontSize.value,
                      min: 12.0,
                      max: 40.0,
                      divisions: 28,
                      label: '${controller.selectedFontSize.value.toInt()} pt',
                      onChanged: controller.setFontSize,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.selectedFontSize.value.toInt()} pt',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

          if (mode == AnnotationMode.erase)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Tap or drag over drawings or text annotations to erase them.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Dialog for Adding Text Annotations
  void _showAddTextDialog(BuildContext context, Offset position) {
    final textEditingController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Text Annotation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter text annotation...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (textEditingController.text.trim().isNotEmpty) {
                controller.addTextAnnotation(
                  textEditingController.text,
                  position,
                );
              }
              Get.back();
            },
            child: const Text('Add Text'),
          ),
        ],
      ),
    );
  }

  IconData _getModeIcon(AnnotationMode mode) {
    switch (mode) {
      case AnnotationMode.draw:
        return Icons.brush_rounded;
      case AnnotationMode.text:
        return Icons.title_rounded;
      case AnnotationMode.erase:
        return Icons.cleaning_services_rounded;
      case AnnotationMode.view:
        return Icons.back_hand_outlined;
    }
  }

  String _getModeInstruction(AnnotationMode mode) {
    switch (mode) {
      case AnnotationMode.draw:
        return 'Drawing Mode Active: Drag finger to draw';
      case AnnotationMode.text:
        return 'Text Mode Active: Tap canvas to place text';
      case AnnotationMode.erase:
        return 'Eraser Active: Tap or drag to remove strokes';
      case AnnotationMode.view:
        return 'View Mode Active';
    }
  }
}
