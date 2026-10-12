import 'package:flutter/material.dart';

import '../app_icon.dart';
import '../theme.dart';
import 'app_text_field.dart';

/// 비밀번호 입력창. 처음에는 가려져 있고, 눈 아이콘으로 보였다 가렸다 한다.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
    this.error,
  });

  final TextEditingController controller;
  final String hint;
  final String? error;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: widget.controller,
    hint: widget.hint,
    error: widget.error,
    icon: AppIcon.lock,
    obscure: _obscured,
    suffix: IconButton(
      onPressed: () => setState(() => _obscured = !_obscured),
      icon: (_obscured ? AppIcon.visibilityoff : AppIcon.visibility).icon(
        color: AppColor.whiteL1,
      ),
    ),
  );
}
