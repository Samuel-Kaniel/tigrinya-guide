import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// A custom text field with consistent styling for the app
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplete;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary),
        validator: validator,
        onChanged: onChanged,
        autofocus: autofocus,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
