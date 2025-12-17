import 'package:flutter/material.dart';

class UiPageEntranceAnim extends StatelessWidget {
  final Animation<double> opacity;
  final Animation<Offset> offset;
  final Widget child;

  const UiPageEntranceAnim({
    super.key,
    required this.opacity,
    required this.offset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: FadeTransition(
        opacity: opacity,
        child: child,
      ),
    );
  }
}
