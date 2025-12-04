import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text, 
    required this.onPressed, 
    this.color=Colors.red, 
    this.textColor = Colors.white, 
    });
    final String text;
    final VoidCallback onPressed;
    final Color color;
    final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style:ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)
        )
      ), child: Text(
        text,
        style:TextStyle(
          color: textColor,
          fontSize:18,
          fontWeight: FontWeight.w600,
        )
      )
      ),
    );
  }
}