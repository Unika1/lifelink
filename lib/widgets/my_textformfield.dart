import 'package:flutter/material.dart';

class MyTextformfield extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;

  const MyTextformfield({
    super.key, 
    required this.labelText, 
    required this.hintText, 
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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