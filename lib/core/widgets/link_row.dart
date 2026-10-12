import 'package:flutter/material.dart';

import '../theme.dart';

/// "계정이 없으신가요? 회원가입"
class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.question,
    required this.action,
    required this.onPressed,
  });

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AppText.medium(14, AppColor.whiteL1).text(question),
      TextButton(
        onPressed: onPressed,
        child: AppText.medium(14, AppColor.yellow).text(action),
      ),
    ],
  );
}
