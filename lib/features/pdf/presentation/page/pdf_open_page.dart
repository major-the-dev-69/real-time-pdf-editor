import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../controller/pdf_edit_controller.dart';
import '../widgets/annotation_painter.dart';

class PdfOpenPage extends StatefulWidget {
  const PdfOpenPage({super.key});

  @override
  State<PdfOpenPage> createState() => _PdfOpenPageState();
}

class _PdfOpenPageState extends State<PdfOpenPage> {
  late TransformationController _transformationController;
  final controller = Get.find<PdfEditController>();

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    controller.setZoomScale(scale);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = SharedPrefManager().userRoleEnum;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.hasUnsavedChanges) {
          _showExitConfirmationDialog(context, onExit: () => Get.back());
        } else {
          Get.back();
        }
      },
      child: Scaffold(
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
            onPressed: () {
              if (controller.hasUnsavedChanges) {
                _showExitConfirmationDialog(context, onExit: () => Get.back());
              } else {
                Get.back();
              }
            },
          ),
          actions: [
            Obx(() {
              final hasError =
                  controller.isPdfLoadError.value ||
                  controller.effectivePdfUrl.value.isEmpty;
              final isLoaded = controller.isLoaded.value;
              if (hasError || !isLoaded) return const SizedBox.shrink();

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                      onPressed: () => _showClearAnnotationsDialog(context),
                    ),
                ],
              );
            }),
          ],
        ),
        body: Column(
          children: [
            // Mode Switcher Header Toolbar
            Obx(() {
              final hasError =
                  controller.isPdfLoadError.value ||
                  controller.effectivePdfUrl.value.isEmpty;
              final isLoaded = controller.isLoaded.value;
              if (!userRole.canDraw || hasError || !isLoaded) {
                return const SizedBox.shrink();
              }
              return _buildModeToolbar(context);
            }),

            // PDF Viewer Canvas & Interactive Annotation Layer Stack
            Expanded(
              child: Stack(
                children: [
                  // Integrated Zoomable PDF Viewer & Synchronized Annotation Layer
                  Obx(() {
                    final pdfUrl = controller.effectivePdfUrl.value;
                    final isFetching = controller.isFetchingDetails.value;
                    final isError = controller.isPdfLoadError.value;
                    final mode = controller.activeMode.value;

                    if (isFetching && pdfUrl.isEmpty && !isError) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (isError || pdfUrl.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer
                                      .withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 56,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'PDF Not Available',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'The requested PDF document could not be loaded or the file URL is invalid.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                title: 'Go Back',
                                icon: Icons.arrow_back_rounded,
                                width: 160,
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1.0,
                      maxScale: 5.0,
                      panEnabled: controller.zoomScale.value > 1.0,
                      scaleEnabled: true,
                      child: Stack(
                        children: [
                          // PDF Viewer
                          AbsorbPointer(
                            absorbing: true,
                            child: SfPdfViewer.network(
                              pdfUrl,
                              pageLayoutMode: PdfPageLayoutMode.single,
                              controller: controller.pdfViewerController,
                              scrollDirection: PdfScrollDirection.vertical,
                              enableDoubleTapZooming: false,
                              initialZoomLevel: 1,
                              maxZoomLevel: 1,
                              onDocumentLoaded: (details) {
                                controller.totalPages.value =
                                    details.document.pages.count;
                                controller.isLoaded.value = true;
                              },
                              onDocumentLoadFailed: (details) {
                                controller.isPdfLoadError.value = true;
                                controller.isLoaded.value = false;
                                CustomSnackBar.showError(
                                  title: 'Document Load Error',
                                  message: details.description,
                                );
                              },
                              onPageChanged: (details) {
                                controller.currentPage.value =
                                    details.newPageNumber;
                              },
                            ),
                          ),

                          // Interactive CustomPaint Annotation Layer (only visible when PDF is loaded properly)
                          if (controller.isLoaded.value)
                            Positioned.fill(
                              child: IgnorePointer(
                                ignoring: mode == AnnotationMode.view,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final renderSize = Size(
                                      constraints.maxWidth,
                                      constraints.maxHeight,
                                    );
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: (details) {
                                        if (mode == AnnotationMode.text) {
                                          final hitText = controller
                                              .findTextAnnotationAt(
                                                details.localPosition,
                                                renderSize,
                                              );
                                          if (hitText != null) {
                                            controller.startDraggingText(
                                              hitText,
                                              details.localPosition,
                                              renderSize,
                                            );
                                            return;
                                          }
                                        }
                                        controller.startLine(
                                          details.localPosition,
                                          renderSize,
                                        );
                                      },
                                      onPanUpdate: (details) {
                                        if (mode == AnnotationMode.text &&
                                            controller.isDraggingText.value) {
                                          controller.updateDraggingText(
                                            details.localPosition,
                                            renderSize,
                                          );
                                          return;
                                        }
                                        controller.updateLine(
                                          details.localPosition,
                                          renderSize,
                                        );
                                      },
                                      onPanEnd: (details) {
                                        if (mode == AnnotationMode.text &&
                                            controller.isDraggingText.value) {
                                          controller.endDraggingText();
                                          return;
                                        }
                                        controller.endLine();
                                      },
                                      onTapUp: (details) {
                                        if (mode == AnnotationMode.text) {
                                          final hitText = controller
                                              .findTextAnnotationAt(
                                                details.localPosition,
                                                renderSize,
                                              );
                                          if (hitText != null) {
                                            controller.selectTextAnnotation(
                                              hitText,
                                            );
                                          } else {
                                            controller
                                                .clearSelectedTextAnnotation();
                                            _showAddTextDialog(
                                              context,
                                              details.localPosition,
                                              renderSize,
                                            );
                                          }
                                        } else if (mode ==
                                            AnnotationMode.cross) {
                                          controller.addCrossAnnotation(
                                            details.localPosition,
                                            renderSize,
                                          );
                                        } else if (mode ==
                                            AnnotationMode.erase) {
                                          controller.eraseNear(
                                            details.localPosition,
                                            renderSize,
                                          );
                                        }
                                      },
                                      child: Obx(() {
                                        return CustomPaint(
                                          painter: AnnotationPainter(
                                            lines: controller.lines.toList(),
                                            currentLine:
                                                controller.currentLine.value,
                                            textAnnotations: controller
                                                .textAnnotations
                                                .toList(),
                                            crossAnnotations: controller
                                                .crossAnnotations
                                                .toList(),
                                            currentPage:
                                                controller.currentPage.value,
                                            scale: controller.zoomScale.value,
                                            selectedTextId: controller
                                                .selectedTextAnnotationId
                                                .value,
                                            draggedTextId:
                                                controller.draggedTextId.value,
                                          ),
                                          child: const SizedBox.expand(),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Layer 2: View Mode Active Indicator Banner
                  Obx(() {
                    final hasError =
                        controller.isPdfLoadError.value ||
                        controller.effectivePdfUrl.value.isEmpty;
                    final isLoaded = controller.isLoaded.value;
                    if (hasError ||
                        !isLoaded ||
                        controller.activeMode.value == AnnotationMode.view) {
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
                                _getModeInstruction(
                                  controller.activeMode.value,
                                ),
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

                  // Layer 3: Floating Page Navigation Controls (Only visible if totalPages > 1)
                  Obx(() {
                    final hasError =
                        controller.isPdfLoadError.value ||
                        controller.effectivePdfUrl.value.isEmpty;
                    final isLoaded = controller.isLoaded.value;
                    final totalPages = controller.totalPages.value;
                    final currentPage = controller.currentPage.value;

                    if (hasError || !isLoaded || totalPages <= 1) {
                      return const SizedBox.shrink();
                    }

                    final isFirstPage = currentPage <= 1;
                    final isLastPage = currentPage >= totalPages;

                    var isView =
                        controller.activeMode.value != AnnotationMode.view;

                    var btm = isView
                        ? 12.0
                        : context.mediaQueryPadding.bottom + 12;

                    return Positioned(
                      bottom: btm,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.92,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Previous Page Button
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_left_rounded,
                                  color: isFirstPage
                                      ? theme.colorScheme.onSurface.withValues(
                                          alpha: 0.3,
                                        )
                                      : theme.colorScheme.primary,
                                  size: 28,
                                ),
                                tooltip: 'Previous Page',
                                onPressed: isFirstPage
                                    ? null
                                    : () {
                                        controller.pdfViewerController
                                            .previousPage();
                                      },
                              ),

                              // Current / Total Page Label
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  '$currentPage / $totalPages',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),

                              // Next Page Button
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right_rounded,
                                  color: isLastPage
                                      ? theme.colorScheme.onSurface.withValues(
                                          alpha: 0.3,
                                        )
                                      : theme.colorScheme.primary,
                                  size: 28,
                                ),
                                tooltip: 'Next Page',
                                onPressed: isLastPage
                                    ? null
                                    : () {
                                        controller.pdfViewerController
                                            .nextPage();
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Layer 4: Floating Zoom & Scale Controls
                  Obx(() {
                    final hasError =
                        controller.isPdfLoadError.value ||
                        controller.effectivePdfUrl.value.isEmpty;
                    final isLoaded = controller.isLoaded.value;
                    if (hasError || !isLoaded) {
                      return const SizedBox.shrink();
                    }

                    var isNotView =
                        controller.activeMode.value != AnnotationMode.view;

                    final scalePercent = (controller.zoomScale.value * 100)
                        .round();

                    return Positioned(
                      top: isNotView ? Get.height * 0.05 : Get.height * 0.02,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_rounded, size: 20),
                              tooltip: 'Zoom Out',
                              onPressed: controller.zoomScale.value <= 1.0
                                  ? null
                                  : () {
                                      controller.zoomOut();
                                      if (controller.zoomScale.value < 1.0) {
                                        controller.setZoomScale(1.0);
                                      }
                                      _transformationController.value =
                                          Matrix4.diagonal3Values(
                                            controller.zoomScale.value,
                                            controller.zoomScale.value,
                                            1.0,
                                          );
                                    },
                            ),
                            InkWell(
                              onTap: () {
                                controller.resetZoom();
                                _transformationController.value =
                                    Matrix4.identity();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Text(
                                  '$scalePercent%',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, size: 20),
                              tooltip: 'Zoom In',
                              onPressed: () {
                                controller.zoomIn();
                                _transformationController.value =
                                    Matrix4.diagonal3Values(
                                      controller.zoomScale.value,
                                      controller.zoomScale.value,
                                      1.0,
                                    );
                              },
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
            Obx(() {
              final hasError =
                  controller.isPdfLoadError.value ||
                  controller.effectivePdfUrl.value.isEmpty;
              final isLoaded = controller.isLoaded.value;
              if (!userRole.canDraw ||
                  hasError ||
                  !isLoaded ||
                  controller.activeMode.value == AnnotationMode.view) {
                return const SizedBox.shrink();
              }
              return _buildBottomControlPanel(context);
            }),
          ],
        ),
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

    var bottom = context.mediaQueryPadding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
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
                    padding: EdgeInsets.only(bottom: 8),
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
                                          blurRadius: 6,
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
          ],

          if (mode == AnnotationMode.draw) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stroke Width',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${controller.selectedStrokeWidth.value.toInt()} px',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
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
                      const SizedBox(width: 8),
                      Obx(
                        () => Container(
                          width: 24,
                          height: 24,
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
                ],
              ),
            ),
          ],

          if (mode == AnnotationMode.text) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Font Size',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${controller.selectedFontSize.value.toInt()} pt',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Slider(
                            padding: EdgeInsets.zero,
                            value: controller.selectedFontSize.value,
                            min: 10.0,
                            max: 48.0,
                            divisions: 38,
                            label:
                                '${controller.selectedFontSize.value.toInt()} pt',
                            onChanged: controller.setFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Thickness / Font Weight Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thickness',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(
                              () => Text(
                                _getFontWeightName(
                                  controller.selectedFontWeight.value,
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Slider(
                            padding: EdgeInsets.zero,
                            value: _fontWeightToSliderValue(
                              controller.selectedFontWeight.value,
                            ),
                            min: 1.0,
                            max: 9.0,
                            divisions: 8,
                            label: _getFontWeightName(
                              controller.selectedFontWeight.value,
                            ),
                            onChanged: (val) => controller.setFontWeight(
                              _sliderValueToFontWeight(val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Obx(() {
              final isSelected =
                  controller.selectedTextAnnotationId.value.isNotEmpty;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected
                        ? Icons.touch_app_rounded
                        : Icons.open_with_rounded,
                    size: 14,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isSelected
                          ? 'Drag selected text to reposition or adjust style'
                          : 'Tap to add text or drag existing text to move',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => controller.clearSelectedTextAnnotation(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          'Deselect',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],

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

  // Dialog for Exit Confirmation when Unsaved Changes Exist
  void _showExitConfirmationDialog(
    BuildContext context, {
    required VoidCallback onExit,
    VoidCallback? onStay,
  }) {
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade800,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Unsaved Changes',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You have unsaved annotations on this PDF. Exiting now will discard your drawing and text changes.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Column(
                children: [
                  CustomOutlinedButton(
                    title: 'Keep Editing',
                    height: 48,
                    onPressed: () {
                      Get.back();
                      if (onStay != null) onStay();
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    title: 'Discard & Exit',
                    icon: Icons.exit_to_app_rounded,
                    backgroundColor: theme.colorScheme.error,
                    textColor: theme.colorScheme.onError,
                    height: 48,
                    onPressed: () {
                      Get.back();
                      onExit();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog for Clearing All Annotations
  void _showClearAnnotationsDialog(BuildContext context) {
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Clear Annotations',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to clear all drawing and text annotations? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 28),
              Column(
                children: [
                  CustomOutlinedButton(
                    title: 'Cancel',
                    height: 48,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    title: 'Clear All',
                    icon: Icons.delete_rounded,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    height: 48,
                    onPressed: () {
                      controller.clearAllAnnotations();
                      Get.back();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog for Adding Text Annotations
  void _showAddTextDialog(
    BuildContext context,
    Offset position, [
    Size renderSize = Size.zero,
  ]) {
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
          CustomButton(
            title: 'Add Text',
            width: 120,
            height: 40,
            onPressed: () {
              if (textEditingController.text.trim().isNotEmpty) {
                controller.addTextAnnotation(
                  textEditingController.text,
                  position,
                  renderSize,
                );
              }
              Get.back();
            },
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
      case AnnotationMode.cross:
        return Icons.close_rounded;
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
      case AnnotationMode.cross:
        return "Cross Mode Active: Tap canvas to place cross marker";
    }
  }

  String _getFontWeightName(FontWeight weight) {
    switch (weight) {
      case FontWeight.w100:
        return 'Thin';
      case FontWeight.w200:
        return 'Extra Light';
      case FontWeight.w300:
        return 'Light';
      case FontWeight.w400:
        return 'Regular';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.w600:
        return 'Semi Bold';
      case FontWeight.w700:
        return 'Bold';
      case FontWeight.w800:
        return 'Extra Bold';
      case FontWeight.w900:
        return 'Black';
      default:
        return 'Regular';
    }
  }

  double _fontWeightToSliderValue(FontWeight weight) {
    switch (weight) {
      case FontWeight.w100:
        return 1.0;
      case FontWeight.w200:
        return 2.0;
      case FontWeight.w300:
        return 3.0;
      case FontWeight.w400:
        return 4.0;
      case FontWeight.w500:
        return 5.0;
      case FontWeight.w600:
        return 6.0;
      case FontWeight.w700:
        return 7.0;
      case FontWeight.w800:
        return 8.0;
      case FontWeight.w900:
        return 9.0;
      default:
        return 4.0;
    }
  }

  FontWeight _sliderValueToFontWeight(double value) {
    final val = value.round();
    switch (val) {
      case 1:
        return FontWeight.w100;
      case 2:
        return FontWeight.w200;
      case 3:
        return FontWeight.w300;
      case 4:
        return FontWeight.w400;
      case 5:
        return FontWeight.w500;
      case 6:
        return FontWeight.w600;
      case 7:
        return FontWeight.w700;
      case 8:
        return FontWeight.w800;
      case 9:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }
}
