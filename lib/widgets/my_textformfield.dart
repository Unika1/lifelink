import 'package:flutter/material.dart';

class MyTextformfield extends StatefulWidget {
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
  State<MyTextformfield> createState() => _MyTextformfieldState();
}

class _MyTextformfieldState extends State<MyTextformfield> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _obscured = !_obscured);
                },
              )
            : null,
      ),
    );
  }
}
