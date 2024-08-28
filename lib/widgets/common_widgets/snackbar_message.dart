import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/material.dart';

SnackBar snackBarMessage({
  required BuildContext context,
  required String message,
  required Color backgroundColor,
  double? sidePadding,
  double? bottomPadding,
  Animation<double>? animation,
  Duration? duration,
  DismissDirection? dismissDirection,
  SnackBarAction? snackBarAction
}){
  Size size = MediaQuery.sizeOf(context);
  return SnackBar(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      animation: animation,
      dismissDirection: dismissDirection ?? DismissDirection.horizontal,
      duration: duration ?? const  Duration(seconds: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: sidePadding ?? size.width * 0.1, right: sidePadding ?? size.width * 0.1, bottom: bottomPadding ?? size.height * 0.85),
      content: Center(
        child: TextWidget(
          text: message, 
          fontWeight: FontWeight.w400,
          fontSize: 13,
          fontColor: Colors.white,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: 2,
      action: snackBarAction
    );

}
