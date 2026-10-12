import 'package:flutter/material.dart';

import '../../core/app_icon.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';

/// 로고 + 알림 종 (안 읽은 개수 뱃지). 홈·탐색이 쓴다.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => AppBar(
    leading: Padding(
      padding: const EdgeInsets.only(left: Gap.m),
      child: Image.asset('assets/logo_vertical.png'),
    ),
    leadingWidth: 132,
    backgroundColor: Colors.transparent,
    actions: const [_Bell()],
  );
}

class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) {
    final alerts = context.deps.alerts;
    final bell = AppIcon.notification.icon(color: AppColor.white, size: 28);
    return ListenableBuilder(
      listenable: alerts,
      builder: (context, _) {
        final n = alerts.unreadCount;
        return IconButton(
          key: const Key('alerts'),
          onPressed: () => context.go(Routes.alerts),
          icon: n <= 0
              ? bell
              : Badge(
                  backgroundColor: AppColor.red,
                  label: Text(n > 3 ? '3+' : '$n'),
                  child: bell,
                ),
        );
      },
    );
  }
}
