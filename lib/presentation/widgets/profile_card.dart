import 'package:flutter/material.dart';

import '../../core/app_icon.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/panel.dart';

/// 마이페이지 위쪽: 로그인한 사람 이름·이메일
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.deps.session.user;
    return Panel(
      child: Row(
        spacing: Gap.m,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColor.yellow.withAlpha(80),
            child: AppIcon.person.icon(color: AppColor.yellow, size: 28),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Gap.xs,
              children: [
                AppText.bold(16).text(user?.name ?? ''),
                AppText.medium(12, AppColor.whiteL1).text(user?.email ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
