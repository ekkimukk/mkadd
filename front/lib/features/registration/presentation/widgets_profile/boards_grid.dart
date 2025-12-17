import 'package:flutter/material.dart';
import '../widgets_ui/ui_page_entrance_anim.dart';

class BoardsGrid extends StatelessWidget {
  final Animation<double> opacity;
  final Animation<Offset> offset;
  final List<Widget> children;

  const BoardsGrid({
    super.key,
    required this.opacity,
    required this.offset,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return UiPageEntranceAnim(
      opacity: opacity,
      offset: offset,
      child: GridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        crossAxisCount: 5,
        mainAxisSpacing: 22,
        crossAxisSpacing: 22,
        children: children,
      ),
    );
  }
}
