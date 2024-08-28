import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  final int? maxLines;
  final TextDecoration? textDecoration;
  final Color? fontColor;
  final TextOverflow? textOverflow;
  const TextWidget({
    super.key,
    required this.text,
    this.fontColor,
    this.maxLines,
    this.textDecoration,
    this.textOverflow,
    required this.fontWeight,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: fontColor,
        decoration: textDecoration
      ),
    );
  }
}