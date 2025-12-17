import 'package:flutter/material.dart';

class UiPrimaryButton extends StatefulWidget {
  final String text;
  final bool isDark;
  final VoidCallback onPressed;

  const UiPrimaryButton({
    super.key,
    required this.text,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<UiPrimaryButton> createState() => _UiPrimaryButtonState();
}

class _UiPrimaryButtonState extends State<UiPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDark
                ? [const Color(0x0D102FFF), const Color(0x0E2050FF)]
                : [const Color(0x9DBCB2FF), const Color(0x6092B4FF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _pressed
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
