// // lib/features/whiteboard/presentation/providers/whiteboard_elements_provider.dart
// import 'dart:ui';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../toolbars_elements/whiteboard_element.dart';
// import '../toolbars_elements/text_element.dart' as toolbar_text;
// import '../toolbars_elements/shape_element.dart' as toolbar_shape;
//
// final whiteboardElementsProvider =
//     StateNotifierProvider<
//       WhiteboardElementsController,
//       List<WhiteboardElement>
//     >((ref) => WhiteboardElementsController());
//
// class WhiteboardElementsController
//     extends StateNotifier<List<WhiteboardElement>> {
//   WhiteboardElementsController() : super([]);
//
//   void addText(Offset pos, String text, Color color, double fontSize) {
//     state = [
//       ...state,
//       toolbar_text.TextElement(
//         text: text,
//         position: pos,
//         color: color,
//         fontSize: fontSize,
//       ),
//     ];
//   }
//
//   void addShape(
//     Offset pos,
//     toolbar_shape.ShapeType type,
//     Color stroke,
//     double width,
//   ) {
//     state = [
//       ...state,
//       toolbar_shape.ShapeElement(
//         position: pos,
//         type: type,
//         strokeColor: stroke,
//         strokeWidth: width,
//       ),
//     ];
//   }
//
//   void selectElement(WhiteboardElement element) {
//     state = [for (final e in state) e..isSelected = false];
//     element.isSelected = true;
//     state = [...state];
//   }
//
//   void moveElement(WhiteboardElement element, Offset delta) {
//     element.position += delta;
//     state = [...state];
//   }
//
//   void scaleElement(WhiteboardElement element, double factor) {
//     element.scale *= factor;
//     state = [...state];
//   }
//
//   void updateText(toolbar_text.TextElement element, String newText) {
//     element.text = newText;
//     state = [...state];
//   }
// }
