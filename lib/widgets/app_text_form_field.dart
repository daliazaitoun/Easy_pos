import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final String? suffixText;
  final TextInputAction? textInputAction;
  const AppTextFormField(
      {required this.controller,
      required this.validator,
      required this.label,
      this.formatters,
      this.keyboardType,
      this.suffixText,
      this.textInputAction,
    
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: textInputAction,
      inputFormatters: formatters,
      keyboardType: keyboardType,
    
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        suffixText: suffixText,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
