import 'package:flutter/material.dart';

import '../app_icon.dart';
import '../theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.error,
    this.icon,
    this.suffix,
    this.obscure = false,
    this.maxLength,
    this.maxLines = 1,
    this.center = false,
    this.focusNode,
    this.onChanged,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? error;
  final AppIcon? icon;
  final Widget? suffix;
  final bool obscure;
  final int? maxLength;
  final int maxLines;
  final bool center;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    obscureText: obscure,
    obscuringCharacter: '*',
    maxLength: maxLength,
    maxLines: maxLines,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: AppText.input,
    onChanged: onChanged,
    onTap: onTap,
    decoration: AppStyle.input(
      hint: hint,
      error: error,
      icon: icon,
      suffix: suffix,
    ),
  );
}
