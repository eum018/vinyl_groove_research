import 'package:flutter/material.dart';

import '../app_icon.dart';
import '../theme.dart';
import 'trailing_arrow.dart';

/// 마이페이지 메뉴 한 줄
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.arrow = true,
  });

  final AppIcon icon;
  final String label;
  final VoidCallback onTap;
  final bool arrow;

  @override
  Widget build(BuildContext context) => Material(
    clipBehavior: Clip.hardEdge,
    color: AppColor.background,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Gap.l),
        child: Row(
          spacing: Gap.l,
          children: [
            icon.icon(color: AppColor.whiteL1, size: Gap.xl),
            Expanded(child: AppText.medium(16, AppColor.whiteL1).text(label)),
            if (arrow) const TrailingArrow(),
          ],
        ),
      ),
    ),
  );
}
