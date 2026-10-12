import 'package:flutter/material.dart';

import '../theme.dart';

/// ─── 또는 ───
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Gap.s),
    child: Row(
      spacing: Gap.m,
      children: [
        const Expanded(child: Divider(color: AppColor.whiteL1)),
        AppText.medium(14, AppColor.whiteL1).text('또는'),
        const Expanded(child: Divider(color: AppColor.whiteL1)),
      ],
    ),
  );
}
