import 'package:flutter/material.dart';

class TextFields extends StatelessWidget {
  final String? hintText;
  final bool isObseure;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final bool? readOnly;
  final int? maxLines;
  final double? borderRadius;
  final VoidCallback? onEditingComplete;
  final Function(String value)? onChanged;
  final Function(String value)? onFieldSubmitted;
  final String? Function(String? value)? validator;
  final VoidCallback? onTap;
  final String? labelText;
  final Color? borderColor;
  final String? initalValue;
  final TextEditingController? controller;
  const TextFields({
    super.key, 
    this.hintText, 
    this.controller, 
    required this.isObseure,
    this.suffixIcon,
    this.onTap,
    this.borderRadius,
    this.readOnly,
    this.maxLines,
    this.onEditingComplete,
    this.focusNode,
    this.initalValue,
    this.borderColor,
    this.labelText,
    this.onFieldSubmitted,
    this.onChanged, 
    this.prefixIcon,
    this.validator,
    this.keyboardType, 
    required this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: size.width > 600 ? size.width  : size.width
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObseure,
        initialValue: initalValue,
        focusNode: focusNode,
        keyboardType: keyboardType,
        readOnly: readOnly ?? false,
        onTap: onTap,
        textInputAction: textInputAction,
        obscuringCharacter: '*',
        onChanged: onChanged,
        maxLines: maxLines ?? 1,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        validator: validator,
        style: TextStyle(
          fontSize: 15,
          color: const Color(0xFF656872).withValues(alpha: 1.0)
        ),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          alignLabelWithHint: false,
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:Colors.grey.withValues(alpha: 0.5)
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color:Colors.grey.withValues(alpha: 0.5)
          ),
          suffixIcon: suffixIcon,
          suffixIconColor: const Color(0xFF656872).withValues(alpha: 1.0),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color:Colors.grey.withValues(alpha: 0.5)
          ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            borderSide: BorderSide(
              color: borderColor ?? const Color(0xFF656872).withValues(alpha: 0.1)
            )
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            borderSide: BorderSide(
              color:  borderColor ?? const Color(0xFF656872).withValues(alpha: 0.1)
            )
          ),
          fillColor: const Color(0xFF656872).withValues(alpha: 0.1),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            borderSide: const BorderSide(
              color: Colors.redAccent
            )
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            borderSide: BorderSide(
              color:  borderColor ?? const Color(0xFF656872).withValues(alpha: 0.1)
            )
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            borderSide: BorderSide(
              color:  borderColor ?? const Color(0xFF656872).withValues(alpha: 0.0)
            )
          )
        ),
      ),
    );
    
  }
}
 