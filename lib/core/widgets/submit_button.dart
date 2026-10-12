import 'package:flutter/material.dart';

import '../theme.dart';

/// 화면 아래 노란 큰 버튼 (로그인·회원가입·등록하기·구매하기)
class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: AppStyle.primary,
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(label, style: AppText.bold(16, null))],
    ),
  );
}
