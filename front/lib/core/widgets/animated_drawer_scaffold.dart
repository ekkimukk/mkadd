import 'package:flutter/material.dart';

class AnimatedDrawerScaffold extends StatefulWidget {
  final Widget drawer;
  final Widget content;

  const AnimatedDrawerScaffold({
    super.key,
    required this.drawer,
    required this.content,
  });

  @override
  AnimatedDrawerScaffoldState createState() => AnimatedDrawerScaffoldState();
}

class AnimatedDrawerScaffoldState extends State<AnimatedDrawerScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  bool get isOpen => _controller.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  /// API для открытия/закрытия через GlobalKey
  void toggleDrawer() => isOpen ? close() : open();
  void open() => _controller.forward();
  void close() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.content,
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 260,
              child: Material(color: Colors.transparent, child: widget.drawer),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
