import 'package:flutter/material.dart';

import '../theme.dart';

/// 통신 실패 화면: 안내 문구 + 다시 시도
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Gap.s,
      children: [
        const Icon(Icons.wifi_off, color: AppColor.whiteL3, size: 40),
        AppText.medium(
          14,
          AppColor.whiteL1,
        ).text(message, align: TextAlign.center),
        TextButton(
          key: const Key('retry'),
          onPressed: onRetry,
          child: AppText.bold(14, AppColor.yellow).text('다시 시도'),
        ),
      ],
    ),
  );
}
