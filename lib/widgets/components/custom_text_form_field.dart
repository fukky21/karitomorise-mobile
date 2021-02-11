import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.maxLines = 1,
    this.obscureText = false,
    this.labelText,
    this.errorText,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLength;
  final bool maxLengthEnforced;
  final int maxLines;
  final bool obscureText;
  final String labelText;
  final String errorText;
  final String Function(String) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLengthEnforced: maxLengthEnforced,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
