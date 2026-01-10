import 'package:flutter/material.dart';

class MyTextformfield extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const MyTextformfield({
    super.key, 
    required this.labelText, 
    required this.hintText, 
    required this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        )
      ),
    );
  }
}