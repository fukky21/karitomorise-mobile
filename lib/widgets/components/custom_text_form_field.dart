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
    this.hintText,
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
  final String hintText;
  final String errorText;
  final String Function(String) validator;

  @override
  Widget build(BuildContext context) {
    if (labelText != null) {
      return Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              labelText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 3),
          _textFormField(),
        ],
      );
    }

    return _textFormField();
  }

  Widget _textFormField() {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLengthEnforced: maxLengthEnforced,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
