import 'package:flutter/material.dart';

import '../../domain/enums.dart';
import '../theme.dart';

/// 음반 등급 뱃지 (M, NM, VG+ ...)
class ConditionBadge extends StatelessWidget {
  const ConditionBadge(
    this.condition, {
    super.key,
    this.fontSize = 10,
    this.color = AppColor.white,
  });

  final Condition condition;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColor.badge,
      borderRadius: BorderRadius.circular(4),
    ),
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: AppText.medium(
      fontSize,
      color,
    ).text(condition.code, overflow: TextOverflow.ellipsis),
  );
}
