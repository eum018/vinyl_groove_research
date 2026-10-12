import 'package:flutter/material.dart';

import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/confirm_dialog.dart';

/// 로그아웃: 확인 → Store 전부 비우기 → 로그인 화면 (뒤로 가기로 못 돌아온다)
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await AppConfirmDialog.show(
      context,
      title: '정말 로그아웃 하시겠습니까?',
      confirm: '로그아웃',
    );
    if (!ok || !context.mounted) return;
    await context.deps.logout();
    if (context.mounted) context.reset(Routes.login);
  }

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: const Key('logout'),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.background,
      foregroundColor: AppColor.red,
      side: const BorderSide(color: AppColor.red),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    onPressed: () => _logout(context),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [AppText.bold(16, null).text('로그아웃')],
    ),
  );
}
