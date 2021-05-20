import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.maxLengthEnforcement = MaxLengthEnforcement.enforced,
    this.maxLines = 1,
    this.obscureText = false,
    this.labelText,
    this.errorText,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLength;
  final MaxLengthEnforcement maxLengthEnforcement;
  final int maxLines;
  final bool obscureText;
  final String labelText;
  final String errorText;
  final String Function(String) validator;
  final void Function(String) onChanged;

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
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
