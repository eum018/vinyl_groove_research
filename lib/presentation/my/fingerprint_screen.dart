import 'package:flutter/material.dart';

import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets/title_app_bar.dart';

/// 지문 로그인 자리 (기능은 아직 없다)
class FingerprintScreen extends StatelessWidget {
  const FingerprintScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: const TitleAppBar(title: '간편 로그인', back: false, center: true),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: Center(
        child: TextButton(
          onPressed: () => context.go(Routes.login),
          child: AppText.medium(14, AppColor.yellow).text('다른 계정으로 로그인하기'),
        ),
      ),
    ),
  );
}
