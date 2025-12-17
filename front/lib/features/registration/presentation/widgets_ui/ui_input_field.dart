import 'package:flutter/material.dart';

class UiInputField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextInputType inputType;
  final bool isDark;

  const UiInputField({
    super.key,
    required this.label,
    required this.isPassword,
    required this.isDark,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: inputType,
        validator: (value) => value!.isEmpty ? "Введите $label" : null,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.blueGrey.shade200,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.blueAccent.withOpacity(0.5)
                  : const Color(0xFF031FFF),
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
