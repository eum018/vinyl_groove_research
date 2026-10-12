import 'package:flutter/material.dart';

import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/widgets/pin_page.dart';

/// PIN 설정 1단계
class PinScreen extends StatelessWidget {
  const PinScreen({super.key});

  @override
  Widget build(BuildContext context) => PinPage(
    key: const Key('pin_setup'),
    title: 'PIN 번호를 설정해주세요',
    message: '4자리 PIN 번호를 입력해주세요',
    check: (pin) async {
      final err = context.deps.pins.draft(pin);
      if (err == null) context.re(Routes.pinCheck);
      return err;
    },
  );
}

/// PIN 설정 2단계 — 같은 번호를 한 번 더
class PinCheckScreen extends StatelessWidget {
  const PinCheckScreen({super.key});

  @override
  Widget build(BuildContext context) => PinPage(
    key: const Key('pin_check'),
    title: 'PIN 번호를 재확인해주세요',
    message: '같은 PIN 번호를 다시 입력해주세요',
    check: (pin) async {
      final err = await context.deps.pins.confirm(pin);
      if (err == null && context.mounted) context.go(Routes.pinLogin);
      return err;
    },
  );
}
