// lib/features/whiteboard/presentation/widgets/whiteboard_view.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';
import 'package:miro_prototype/models/draw_message.dart';
import 'package:miro_prototype/services/websocket_service.dart';
import 'package:miro_prototype/whiteboard_providers.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/whiteboard_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/text_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/shape_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/path_element.dart';

class WhiteboardView extends ConsumerWidget {
  final String boardId;
  const WhiteboardView({super.key, required this.boardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraProvider(boardId));
    final elements = ref.watch(elementsProvider(boardId));
    final toolState = ref.watch(toolStateProvider);

    return _WhiteboardGestureHandler(
      boardId: boardId,
      camera: camera,
      elements: elements,
      toolState: toolState,
      notifier: ref.read(elementsProvider(boardId).notifier),
      ws: ref.read(websocketServiceProvider(boardId)),
    );
  }
}

class _WhiteboardGestureHandler extends ConsumerStatefulWidget {
  final String boardId;
  final CameraState camera;
  final List<WhiteboardElement> elements;
  final ToolState toolState;
  final ElementsNotifier notifier;
  final WebSocketService ws;

  const _WhiteboardGestureHandler({
    required this.boardId,
    required this.camera,
    required this.elements,
    required this.toolState,
    required this.notifier,
    required this.ws,
  });

  @override
  ConsumerState<_WhiteboardGestureHandler> createState() =>
      _WhiteboardGestureHandlerState();
}

class _WhiteboardGestureHandlerState
    extends ConsumerState<_WhiteboardGestureHandler> {
  late ui.Offset _lastFocalPoint;
  late ui.Path _currentPath;
  late ui.Offset _lastPoint;
  bool _isDrawing = false;
  late List<Point> _currentPoints;
  final GlobalKey _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentPath = ui.Path();
    _currentPoints = [];
    _isDrawing = false;
    _lastFocalPoint = ui.Offset.zero;
  }

  ui.Offset _getLocalPosition(ui.Offset globalPosition, CameraState camera) {
    final renderBox =
        _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return ui.Offset.zero;

    final localPosition = renderBox.globalToLocal(globalPosition);
    return ui.Offset(
      (localPosition.dx - camera.offset.dx) / camera.scale,
      (localPosition.dy - camera.offset.dy) / camera.scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _boardKey,
      onScaleStart: (details) {
        _lastFocalPoint = details.focalPoint;
        if (widget.toolState.currentTool == DrawingTool.brush) {
          if (details.pointerCount == 1 && !_isDrawing) {
            _isDrawing = true;
            final localPos = _getLocalPosition(
              details.focalPoint,
              widget.camera,
            );
            _lastPoint = localPos;
            _currentPath = ui.Path();
            _currentPoints = [Point(localPos.dx, localPos.dy)];
            _currentPath.moveTo(localPos.dx, localPos.dy);
            setState(() {});
          }
        }
      },
      onScaleUpdate: (details) {
        if (widget.toolState.currentTool == DrawingTool.brush && _isDrawing) {
          final localPos = _getLocalPosition(details.focalPoint, widget.camera);
          if (localPos.dx.isFinite && localPos.dy.isFinite) {
            _currentPath.quadraticBezierTo(
              _lastPoint.dx,
              _lastPoint.dy,
              (localPos.dx + _lastPoint.dx) / 2,
              (localPos.dy + _lastPoint.dy) / 2,
            );
            _currentPoints.add(Point(localPos.dx, localPos.dy));
            _lastPoint = localPos;
            setState(() {});
          }
        } else if (widget.toolState.currentTool == DrawingTool.hand) {
          final newFocalPoint = details.focalPoint;
          final deltaScale = details.scale;
          final delta = (newFocalPoint - _lastFocalPoint) / widget.camera.scale;
          final newScale = (widget.camera.scale * deltaScale).clamp(0.2, 5.0);
          final focal = newFocalPoint;
          final oldOffset = widget.camera.offset;
          final newOffset =
              focal -
              (focal - (oldOffset + delta)) * (newScale / widget.camera.scale);

          ref.read(cameraProvider(widget.boardId).notifier).state = CameraState(
            offset: newOffset,
            scale: newScale,
          );
        }
        _lastFocalPoint = details.focalPoint;
      },
      onScaleEnd: (details) {
        if (widget.toolState.currentTool == DrawingTool.brush && _isDrawing) {
          if (_currentPath != ui.Path()) {
            final drawData = DrawData(
              path: _currentPoints,
              color: _colorToString(widget.toolState.brushColor),
              strokeWidth: widget.toolState.strokeWidth,
            );

            widget.ws.sendMessage({
              'type': 'draw',
              'data': drawData.toJson(),
              'timestamp': DateTime.now().toIso8601String(),
            });

            widget.notifier.addElement(
              PathElement(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                position: ui.Offset.zero,
                path: ui.Path.from(_currentPath),
                color: widget.toolState.brushColor,
                strokeWidth: widget.toolState.strokeWidth,
              ),
            );
          }
          _currentPath = ui.Path();
          _isDrawing = false;
          setState(() {});
        }
      },
      child: CustomPaint(
        painter: _WhiteboardPainter(
          elements: widget.elements,
          offset: widget.camera.offset,
          scale: widget.camera.scale,
          currentPath: ui.Path.from(_currentPath),
          currentPathColor: widget.toolState.brushColor,
          currentPathStrokeWidth: widget.toolState.strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }

  String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<WhiteboardElement> elements;
  final ui.Offset offset;
  final double scale;
  final ui.Path currentPath;
  final Color currentPathColor;
  final double currentPathStrokeWidth;

  _WhiteboardPainter({
    required this.elements,
    required this.offset,
    required this.scale,
    required this.currentPath,
    this.currentPathColor = Colors.black,
    this.currentPathStrokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    _drawGrid(canvas, size);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final element in elements) {
      if (element is TextElement) {
        _drawText(canvas, element);
      } else if (element is ShapeElement) {
        paint.color = element.color;
        paint.strokeWidth = 2.0;
        canvas.drawRect(
          Rect.fromLTWH(
            element.position.dx,
            element.position.dy,
            element.size.width,
            element.size.height,
          ),
          paint,
        );
      } else if (element is PathElement) {
        paint.color = element.color;
        paint.strokeWidth = element.strokeWidth;
        canvas.drawPath(element.path, paint);
      }
    }

    if (currentPath != ui.Path()) {
      paint.color = currentPathColor;
      paint.strokeWidth = currentPathStrokeWidth;
      canvas.drawPath(currentPath, paint);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFF8F9FA);
    canvas.drawRect(
      Rect.fromLTWH(
        -offset.dx / scale,
        -offset.dy / scale,
        size.width / scale,
        size.height / scale,
      ),
      backgroundPaint,
    );

    final gridPaint = Paint();
    const baseGridSize = 50.0;
    final gridSize = baseGridSize;

    final visibleLeft = -offset.dx / scale;
    final visibleTop = -offset.dy / scale;
    final visibleRight = visibleLeft + size.width / scale;
    final visibleBottom = visibleTop + size.height / scale;

    final startCol = (visibleLeft / gridSize).floor();
    final endCol = (visibleRight / gridSize).ceil();
    final startRow = (visibleTop / gridSize).floor();
    final endRow = (visibleBottom / gridSize).ceil();

    gridPaint.color = const Color(0xFFECEFF1);
    gridPaint.strokeWidth = 0.5;

    for (var col = startCol; col <= endCol; col++) {
      final x = col * gridSize;
      canvas.drawLine(
        ui.Offset(x, visibleTop),
        ui.Offset(x, visibleBottom),
        gridPaint,
      );
    }

    for (var row = startRow; row <= endRow; row++) {
      final y = row * gridSize;
      canvas.drawLine(
        ui.Offset(visibleLeft, y),
        ui.Offset(visibleRight, y),
        gridPaint,
      );
    }

    if (visibleLeft <= 0 &&
        visibleRight >= 0 &&
        visibleTop <= 0 &&
        visibleBottom >= 0) {
      final centerPaint = Paint()..color = const Color(0xFFCFD8DC);
      canvas.drawCircle(const ui.Offset(0, 0), 2.0, centerPaint);
    }
  }

  void _drawText(Canvas canvas, TextElement element) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, element.position);
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) {
    return elements != oldDelegate.elements ||
        offset != oldDelegate.offset ||
        scale != oldDelegate.scale ||
        currentPath != oldDelegate.currentPath;
  }
}
