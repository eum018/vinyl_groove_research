import 'package:flutter/cupertino.dart';

import '../theme.dart';

/// 확인 팝업. 확인을 누르면 true, 취소·바깥은 false. 닫기는 팝업이 알아서 한다.
abstract final class AppConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? content,
    required String confirm,
  }) async =>
      await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: AppText.dark.text(title),
          content: content == null ? null : AppText.dark.text(content),
          actions: [
            _action(context, '취소', false),
            _action(context, confirm, true),
          ],
        ),
      ) ??
      false;

  static CupertinoButton _action(BuildContext c, String label, bool r) =>
      CupertinoButton(
        onPressed: () => Navigator.pop(c, r),
        child: AppText.medium(12, AppColor.black).text(label),
      );
}
