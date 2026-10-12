import 'package:flutter/material.dart';

import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/pin_page.dart';

class PinLoginScreen extends StatelessWidget {
  const PinLoginScreen({super.key});

  @override
  Widget build(BuildContext context) => PinPage(
    key: const Key('pin_login'),
    title: '간편 로그인',
    titleSize: null,
    back: false,
    message: '로그인을 위해\n4자리 PIN 번호를 입력해주세요',
    check: (pin) async {
      final err = context.deps.pins.verify(pin);
      if (err == null) context.go(Routes.nav);
      return err;
    },
    footer: TextButton(
      onPressed: () => context.go(Routes.login),
      child: AppText.medium(14, AppColor.yellow).text('다른 계정으로 로그인하기'),
    ),
  );
}
