import 'package:flutter/material.dart';

class CapsuleTextField extends StatelessWidget {
  const CapsuleTextField({
    super.key,
    required this.controller,
    required this.onFieldSubmitted,
    required this.prompt,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.validator,
    this.forceErrorText,
    this.obscureText = false,
    this.obscureButtonCallback,
  });
  final TextEditingController controller;
  final Function(String) onFieldSubmitted;
  final String prompt;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? forceErrorText;
  final bool obscureText;
  final VoidCallback? obscureButtonCallback;
  final Widget? prefixIcon;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: prompt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: prefixIcon,
        ),
        suffixIcon: obscureButtonCallback != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  onPressed: obscureButtonCallback,
                ),
              )
            : null,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      forceErrorText: forceErrorText,
      obscureText: obscureText,
    );
  }
}
