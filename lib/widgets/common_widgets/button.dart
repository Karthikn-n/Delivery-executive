 import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final FontWeight? fontWeight;
  final double? fontSize;
  const ButtonWidget({
    super.key, 
    required this.title, 
    required this.onPressed,
    this.height,
    this.fontWeight,
    this.fontSize,
    this.width
  });

  @override
  Widget build(BuildContext context) {
     return SizedBox(
      height: height ??  kToolbarHeight - 11,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: fontWeight ?? FontWeight.w400,
            color: Colors.white
          ),
        )
      ),
    );

  }
}

class LoadingButton extends StatelessWidget {
  final Color? buttonColor;
  final double? borderRadius;
  final Color? bordercolor;
  final double? width;
  const LoadingButton({
    super.key, 
    this.buttonColor,
    this.borderRadius,
    this.bordercolor,
    this.width
    });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: width ?? size.width * 0.8,
      height: size.height * 0.065,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonColor ?? Theme.of(context).primaryColor,
          surfaceTintColor: Colors.transparent.withOpacity(0.0),
          shadowColor: Colors.transparent.withOpacity(0.0),
          overlayColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            side: BorderSide(
              color: bordercolor ?? Colors.transparent.withOpacity(0.0)
            )
          )
        ),
        onPressed: (){}, 
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white
          ),
        )
      ),
    );
  }
}

