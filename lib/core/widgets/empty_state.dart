import 'package:flutter/material.dart';

import '../app_icon.dart';
import '../theme.dart';

/// 결과 0개 화면. 당겨서 새로고침이 되게 하려면 scrollable: true
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.bright = false,
    this.scrollable = false,
  });

  final String title;
  final String? subtitle;
  final AppIcon? icon;

  /// true면 흰 굵은 글씨 한 줄 (내 등록 상품)
  final bool bright;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Gap.m,
        children: [
          if (icon case final i?) i.icon(color: AppColor.whiteL3, size: 72),
          bright
              ? AppText.bold(14).text(title)
              : AppText.medium(16, AppColor.whiteL3).text(title),
          if (subtitle case final s?)
            AppText.regular(14, AppColor.whiteL3).text(s),
        ],
      ),
    );
    if (!scrollable) return body;
    return LayoutBuilder(
      builder: (context, box) => ListView(
        children: [SizedBox(height: box.maxHeight, child: body)],
      ),
    );
  }
}
