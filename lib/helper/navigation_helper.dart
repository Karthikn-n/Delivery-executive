import 'package:flutter/material.dart';

class SideTransiion<T> extends PageRouteBuilder<T>{
  final Widget screen;
  final Map<String, dynamic>? args;

  SideTransiion({required this.screen, this.args}):super(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1, 0);
      const end = Offset.zero;
      Curve curve = Curves.easeInOut;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation, 
        child: child,
      );
    },
    settings: RouteSettings(arguments: args)
  );
}