import 'package:flutter/material.dart';

import '../theme.dart';

/// "전체 보기 >"
class MoreButton extends StatelessWidget {
  const MoreButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Gap.xs,
      children: [
        AppText.medium(12, AppColor.whiteL1).text('전체 보기'),
        const Icon(Icons.arrow_forward_ios, color: AppColor.whiteL1, size: 12),
      ],
    ),
  );
}
