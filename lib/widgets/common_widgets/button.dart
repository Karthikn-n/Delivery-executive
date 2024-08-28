 import 'package:flutter/material.dart';

class ButtonWidget extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? fontSize;
  const ButtonWidget({
    super.key, 
    required this.title, 
    required this.onPressed,
    this.height,
    this.fontSize,
    this.width
  });

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> with SingleTickerProviderStateMixin{

  late AnimationController _animationController;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    animation = Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
     return SizedBox(
      height: widget.height ??  kToolbarHeight - 11,
      width: widget.width,
      child: InkWell(
        onTapDown: (details) => _animationController.forward(),
        onTapUp: (details) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            )
          ),
          onPressed: widget.onPressed,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: widget.fontSize ?? 18,
              fontWeight: FontWeight.w400,
              color: Colors.white
            ),
          )
        ),
      ),
    );

  }
}

