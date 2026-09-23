import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sai_associates/core/helper/logger_helper.dart';
import 'package:sai_associates/core/network/api_constants.dart';

import '../../../../db/shared_pref_manager.dart';
import '../controller/pdf_edit_controller.dart';
import 'annotation_painter.dart';

class PdfGestureCanvas extends StatefulWidget {
  final PdfEditController controller;
  final String imgUrl;
  final Uint8List? imageBytes;
  final double pageRatio;
  final bool isLoaded;
  final AnnotationMode mode;
  final void Function(BuildContext context, Offset position, Size renderSize)
  onShowAddTextDialog;

  const PdfGestureCanvas({
    super.key,
    required this.controller,
    required this.imgUrl,
    this.imageBytes,
    required this.pageRatio,
    required this.isLoaded,
    required this.mode,
    required this.onShowAddTextDialog,
  });

  @override
  State<PdfGestureCanvas> createState() => _PdfGestureCanvasState();
}

class _PdfGestureCanvasState extends State<PdfGestureCanvas> {
  final Map<int, Offset> _activePointers = {};
  Offset? _lastFocalPoint;
  double? _lastSpan;
  bool _isMultiTouch = false;

  Offset? _singleTouchDownPos;
  DateTime? _singleTouchDownTime;
  bool _isSingleTouchMoved = false;
  Offset? _lastErasePoint;

  Size _getPageSize(Size viewportSize, double ratio) {
    if (ratio <= 0) return viewportSize;
    double width = viewportSize.width;
    double height = width / ratio;
    if (height > viewportSize.height) {
      height = viewportSize.height;
      width = height * ratio;
    }
    return Size(width, height);
  }

  Offset _getPageOffset(Size viewportSize, Size pageSize) {
    return Offset(
      (viewportSize.width - pageSize.width) / 2,
      (viewportSize.height - pageSize.height) / 2,
    );
  }

  Offset _viewportToPageLocalPoint(
    Offset viewportPoint,
    Size viewportSize,
    Size pageSize,
  ) {
    final scenePoint = widget.controller.transformationController.toScene(
      viewportPoint,
    );
    final pageOffset = _getPageOffset(viewportSize, pageSize);
    return scenePoint - pageOffset;
  }

  void _onPointerDown(PointerDownEvent event, Size viewportSize) {
    _activePointers[event.pointer] = event.position;

    if (_activePointers.length >= 2) {
      _isMultiTouch = true;
      _lastErasePoint = null;

      // Cancel any ongoing single-touch drawing or text drag
      if (widget.controller.currentLine.value != null) {
        widget.controller.currentLine.value = null;
      }
      if (widget.controller.isDraggingText.value) {
        widget.controller.isDraggingText.value = false;
        widget.controller.draggedTextId.value = '';
      }

      final p1 = _activePointers.values.elementAt(0);
      final p2 = _activePointers.values.elementAt(1);
      _lastFocalPoint = (p1 + p2) / 2;
      _lastSpan = (p1 - p2).distance;
    } else if (_activePointers.length == 1 && !_isMultiTouch) {
      _singleTouchDownPos = event.localPosition;
      _singleTouchDownTime = DateTime.now();
      _isSingleTouchMoved = false;

      final pageSize = _getPageSize(viewportSize, widget.pageRatio);
      final pageLocalPoint = _viewportToPageLocalPoint(
        event.localPosition,
        viewportSize,
        pageSize,
      );

      final isInsidePage =
          pageLocalPoint.dx >= 0 &&
          pageLocalPoint.dx <= pageSize.width &&
          pageLocalPoint.dy >= 0 &&
          pageLocalPoint.dy <= pageSize.height;

      if (widget.mode == AnnotationMode.text) {
        final hitText = widget.controller.findTextAnnotationAt(
          pageLocalPoint,
          pageSize,
        );
        if (hitText != null) {
          widget.controller.startDraggingText(
            hitText,
            pageLocalPoint,
            pageSize,
          );
        }
      } else if (widget.mode == AnnotationMode.draw && isInsidePage) {
        widget.controller.startLine(pageLocalPoint, pageSize);
      } else if (widget.mode == AnnotationMode.erase && isInsidePage) {
        _lastErasePoint = pageLocalPoint;
        widget.controller.eraseNear(pageLocalPoint, pageSize);
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event, Size viewportSize) {
    _activePointers[event.pointer] = event.position;

    if (_activePointers.length >= 2) {
      _isMultiTouch = true;

      final p1 = _activePointers.values.elementAt(0);
      final p2 = _activePointers.values.elementAt(1);
      final currentFocalPoint = (p1 + p2) / 2;
      final currentSpan = (p1 - p2).distance;

      if (_lastFocalPoint != null && _lastSpan != null && _lastSpan! > 0) {
        final double spanDelta = currentSpan / _lastSpan!;

        final currentMatrix = widget.controller.transformationController.value;
        final currentScale = currentMatrix.getMaxScaleOnAxis();

        final targetScale = (currentScale * spanDelta).clamp(1.0, 20.0);
        final effectiveScaleRatio = targetScale / currentScale;

        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        final localFocal = renderBox != null
            ? renderBox.globalToLocal(_lastFocalPoint!)
            : _lastFocalPoint!;
        final localCurrentFocal = renderBox != null
            ? renderBox.globalToLocal(currentFocalPoint)
            : currentFocalPoint;

        final double oldTx = currentMatrix.storage[12];
        final double oldTy = currentMatrix.storage[13];

        final double newTx =
            localCurrentFocal.dx -
            (localFocal.dx - oldTx) * effectiveScaleRatio;
        final double newTy =
            localCurrentFocal.dy -
            (localFocal.dy - oldTy) * effectiveScaleRatio;

        final newMatrix = Matrix4.identity()
          ..storage[0] = targetScale
          ..storage[5] = targetScale
          ..storage[10] = 1.0
          ..storage[12] = newTx
          ..storage[13] = newTy
          ..storage[15] = 1.0;

        widget.controller.transformationController.value = newMatrix;
        widget.controller.setZoomScale(targetScale);
      }

      _lastFocalPoint = currentFocalPoint;
      _lastSpan = currentSpan;
    } else if (_activePointers.length == 1 && !_isMultiTouch) {
      final moveDist =
          (event.localPosition - (_singleTouchDownPos ?? event.localPosition))
              .distance;
      if (moveDist > 6.0) {
        _isSingleTouchMoved = true;
      }

      if (widget.mode == AnnotationMode.view) {
        // 1-finger panning in View mode
        final currentMatrix = widget.controller.transformationController.value;
        final currentScale = currentMatrix.getMaxScaleOnAxis();
        final newTx = currentMatrix.storage[12] + event.delta.dx;
        final newTy = currentMatrix.storage[13] + event.delta.dy;

        final newMatrix = Matrix4.identity()
          ..storage[0] = currentScale
          ..storage[5] = currentScale
          ..storage[10] = 1.0
          ..storage[12] = newTx
          ..storage[13] = newTy
          ..storage[15] = 1.0;

        widget.controller.transformationController.value = newMatrix;
      } else if (widget.mode == AnnotationMode.draw) {
        final pageSize = _getPageSize(viewportSize, widget.pageRatio);
        final pageLocalPoint = _viewportToPageLocalPoint(
          event.localPosition,
          viewportSize,
          pageSize,
        );
        widget.controller.updateLine(pageLocalPoint, pageSize);
      } else if (widget.mode == AnnotationMode.text &&
          widget.controller.isDraggingText.value) {
        final pageSize = _getPageSize(viewportSize, widget.pageRatio);
        final pageLocalPoint = _viewportToPageLocalPoint(
          event.localPosition,
          viewportSize,
          pageSize,
        );
        widget.controller.updateDraggingText(pageLocalPoint, pageSize);
      } else if (widget.mode == AnnotationMode.erase) {
        final pageSize = _getPageSize(viewportSize, widget.pageRatio);
        final pageLocalPoint = _viewportToPageLocalPoint(
          event.localPosition,
          viewportSize,
          pageSize,
        );
        if (_lastErasePoint == null ||
            (pageLocalPoint - _lastErasePoint!).distance >= 14.0) {
          _lastErasePoint = pageLocalPoint;
          widget.controller.eraseNear(pageLocalPoint, pageSize);
        }
      }
    }
  }

  void _onPointerUp(PointerUpEvent event, Size viewportSize) {
    _activePointers.remove(event.pointer);

    if (_activePointers.isEmpty) {
      _lastErasePoint = null;
      if (_isMultiTouch) {
        _isMultiTouch = false;
        _lastFocalPoint = null;
        _lastSpan = null;

        final scale = widget.controller.transformationController.value
            .getMaxScaleOnAxis();
        if (scale <= 1.02) {
          widget.controller.resetZoom();
        }
      } else {
        if (widget.mode == AnnotationMode.draw) {
          widget.controller.endLine();
        } else if (widget.mode == AnnotationMode.text &&
            widget.controller.isDraggingText.value) {
          widget.controller.endDraggingText();
        } else {
          final isTap =
              !_isSingleTouchMoved &&
              (_singleTouchDownTime != null &&
                  DateTime.now()
                          .difference(_singleTouchDownTime!)
                          .inMilliseconds <
                      450);
          if (isTap) {
            final pageSize = _getPageSize(viewportSize, widget.pageRatio);
            final pageLocalPoint = _viewportToPageLocalPoint(
              event.localPosition,
              viewportSize,
              pageSize,
            );
            final isInsidePage =
                pageLocalPoint.dx >= 0 &&
                pageLocalPoint.dx <= pageSize.width &&
                pageLocalPoint.dy >= 0 &&
                pageLocalPoint.dy <= pageSize.height;

            if (widget.mode == AnnotationMode.text) {
              final hitText = widget.controller.findTextAnnotationAt(
                pageLocalPoint,
                pageSize,
              );
              if (hitText != null) {
                widget.controller.selectTextAnnotation(hitText);
              } else if (isInsidePage) {
                widget.controller.clearSelectedTextAnnotation();
                widget.onShowAddTextDialog(context, pageLocalPoint, pageSize);
              }
            } else if (widget.mode == AnnotationMode.cross && isInsidePage) {
              widget.controller.addCrossAnnotation(pageLocalPoint, pageSize);
            }
          }
        }
      }
    } else if (_activePointers.length == 1) {
      _lastFocalPoint = null;
      _lastSpan = null;
    }
  }

  void _onPointerCancel(PointerCancelEvent event, Size viewportSize) {
    _activePointers.remove(event.pointer);
    if (_activePointers.isEmpty) {
      _isMultiTouch = false;
      _lastFocalPoint = null;
      _lastSpan = null;
      _lastErasePoint = null;
      if (widget.mode == AnnotationMode.draw) {
        widget.controller.endLine();
      } else if (widget.mode == AnnotationMode.text &&
          widget.controller.isDraggingText.value) {
        widget.controller.endDraggingText();
      }
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final currentMatrix = widget.controller.transformationController.value;
      final currentScale = currentMatrix.getMaxScaleOnAxis();
      final double zoomDelta = event.scrollDelta.dy < 0 ? 1.1 : 0.9;
      final targetScale = (currentScale * zoomDelta).clamp(1.0, 20.0);
      final effectiveScaleRatio = targetScale / currentScale;

      final double oldTx = currentMatrix.storage[12];
      final double oldTy = currentMatrix.storage[13];

      final double newTx =
          event.localPosition.dx -
          (event.localPosition.dx - oldTx) * effectiveScaleRatio;
      final double newTy =
          event.localPosition.dy -
          (event.localPosition.dy - oldTy) * effectiveScaleRatio;

      final newMatrix = Matrix4.identity()
        ..storage[0] = targetScale
        ..storage[5] = targetScale
        ..storage[10] = 1.0
        ..storage[12] = newTx
        ..storage[13] = newTy
        ..storage[15] = 1.0;

      widget.controller.transformationController.value = newMatrix;
      widget.controller.setZoomScale(targetScale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _onPointerDown(event, viewportSize),
          onPointerMove: (event) => _onPointerMove(event, viewportSize),
          onPointerUp: (event) => _onPointerUp(event, viewportSize),
          onPointerCancel: (event) => _onPointerCancel(event, viewportSize),
          onPointerSignal: _onPointerSignal,
          child: ClipRect(
            child: InteractiveViewer(
              transformationController:
                  widget.controller.transformationController,
              minScale: 1.0,
              maxScale: 20.0,
              panEnabled: false,
              scaleEnabled: false,
              boundaryMargin: const EdgeInsets.all(500),
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.pageRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // High-DPI Original Quality Image
                      _buildImageView(context),

                      // Annotation Overlay Layer
                      if (widget.isLoaded)
                        Positioned.fill(
                          child: Obx(() {
                            return CustomPaint(
                              painter: AnnotationPainter(
                                lines: widget.controller.lines.toList(),
                                currentLine:
                                    widget.controller.currentLine.value,
                                textAnnotations: widget
                                    .controller
                                    .textAnnotations
                                    .toList(),
                                crossAnnotations: widget
                                    .controller
                                    .crossAnnotations
                                    .toList(),
                                currentPage:
                                    widget.controller.currentPage.value,
                                scale: widget.controller.zoomScale.value,
                                selectedTextId: widget
                                    .controller
                                    .selectedTextAnnotationId
                                    .value,
                                draggedTextId:
                                    widget.controller.draggedTextId.value,
                              ),
                              child: const SizedBox.expand(),
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageView(BuildContext context) {
    return Image.network(
      widget.imgUrl,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _buildLoadingProgress(context, progress);
      },
      headers: _getHeaders(),
      errorBuilder: (context, error, stackTrace) {
        printMessage("⚠️ PDF Error: $error -> $stackTrace");
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Failed to load image',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingProgress(BuildContext context, ImageChunkEvent progress) {
    final theme = Theme.of(context);
    final loadedBytes = progress.cumulativeBytesLoaded;
    final totalBytes = progress.expectedTotalBytes;

    final double? percent = totalBytes != null && totalBytes > 0
        ? (loadedBytes / totalBytes).clamp(0.0, 1.0)
        : null;

    final loadedMbStr = _formatBytes(loadedBytes);
    final totalMbStr = totalBytes != null ? _formatBytes(totalBytes) : null;
    final leftBytes = (totalBytes != null && totalBytes > loadedBytes)
        ? totalBytes - loadedBytes
        : 0;
    final leftMbStr = totalBytes != null ? _formatBytes(leftBytes) : null;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 2.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Loading Document Image',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        percent != null
                            ? '${(percent * 100).toInt()}% completed'
                            : 'Downloading document...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_download_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      totalMbStr != null
                          ? '$loadedMbStr / $totalMbStr'
                          : loadedMbStr,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (leftMbStr != null && leftBytes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$leftMbStr left',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{};
    final token = SharedPrefManager().userToken;
    headers[ApiKeys.authorization] = "Bearer $token";
    return headers;
  }
}
