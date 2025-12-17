import 'package:flutter/material.dart';
import '../widgets_ui/ui_glass_container.dart';

class BoardCard extends StatelessWidget {
  final String id;
  final String name;

  const BoardCard({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UiGlassContainer(
      isDark: isDark,
      child: InkWell(
        onTap: () {
          print('Opening board with ID: $id');
          Navigator.pushReplacementNamed(context, '/whiteboard', arguments: id);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard,
              size: 42,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black87.withOpacity(0.9),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.9)
                    : Colors.black87.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
