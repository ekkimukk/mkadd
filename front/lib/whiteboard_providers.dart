// lib/whiteboard_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/path_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/whiteboard_element.dart';
import 'package:miro_prototype/models/draw_message.dart';
import 'package:miro_prototype/services/websocket_service.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/shape_element.dart';
import 'package:miro_prototype/features/whiteboard/domain/entities/text_element.dart';
import 'dart:ui' as ui;

// ====================================
// 1. StateNotifier для элементов одной доски
// ====================================

class ElementsNotifier extends StateNotifier<List<WhiteboardElement>> {
  ElementsNotifier() : super([]);

  void addElement(WhiteboardElement element) {
    state = [...state, element];
  }

  void clear() {
    state = [];
  }

  void addRemoteMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      final type = message['type'] as String?;

      if (type == 'draw') {
        final data = message['data'] as Map<String, dynamic>?;
        if (data != null) {
          try {
            final drawData = DrawData.fromJson(data);

            final path = ui.Path();
            if (drawData.path.isNotEmpty) {
              path.moveTo(drawData.path[0].x, drawData.path[0].y);
              for (var i = 1; i < drawData.path.length; i++) {
                path.lineTo(drawData.path[i].x, drawData.path[i].y);
              }
            }

            addElement(
              PathElement(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                position: ui.Offset.zero,
                path: path,
                color: _colorFromString(drawData.color),
                strokeWidth: drawData.strokeWidth,
              ),
            );

            print('✅ Added remote path with ${drawData.path.length} points');
          } catch (e) {
            print('❌ Error processing draw message: $e');
          }
        }
      } else if (type == 'clear') {
        clear();
      }
    }
  }
}

Color _colorFromString(String colorStr) {
  try {
    if (colorStr.startsWith('#')) {
      final hex = colorStr.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    if (colorStr == 'black') return Colors.black;
    if (colorStr == 'blue') return Colors.blue;
    if (colorStr == 'red') return Colors.red;
    if (colorStr == 'green') return Colors.green;
    return Colors.black;
  } catch (e) {
    print('Error parsing color $colorStr: $e');
    return Colors.black;
  }
}

// ====================================
// 2. Провайдеры с привязкой к boardId
// ====================================

/// Состояние элементов для конкретной доски
final elementsProvider =
    StateNotifierProvider.family<
      ElementsNotifier,
      List<WhiteboardElement>,
      String
    >((ref, boardId) {
      return ElementsNotifier();
    });

/// Камера (масштаб и сдвиг)
class CameraState {
  final ui.Offset offset;
  final double scale;

  const CameraState({this.offset = ui.Offset.zero, this.scale = 1.0});

  CameraState copyWith({ui.Offset? offset, double? scale}) {
    return CameraState(
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
    );
  }
}

/// Камера тоже привязана к доске (на будущее, если захочешь разные масштабы)
final cameraProvider = StateProvider.family<CameraState, String>((
  ref,
  boardId,
) {
  return const CameraState();
});

/// WebSocket-сервис для конкретной доски
final websocketServiceProvider = Provider.family<WebSocketService, String>((
  ref,
  boardId,
) {
  return WebSocketService(
    ip: 'localhost',
    port: 8080,
    onMessage: (message) {
      ref.read(elementsProvider(boardId).notifier).addRemoteMessage(message);
    },
    onConnect: () {
      print('✅ Connected to WebSocket for board: $boardId');
    },
    onDisconnect: () {
      print('❌ Disconnected from WebSocket for board: $boardId');
    },
  )..connectToBoard(boardId);
});
