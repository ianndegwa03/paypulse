import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.autofocus = false,
    this.focusNode,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ensure high contrast text color
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      focusNode: focusNode,
      obscureText: obscureText,
      validator: validator,
      autofillHints: autofillHints,
      cursorColor: theme.colorScheme.primary,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
