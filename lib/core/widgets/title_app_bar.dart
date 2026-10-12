import 'package:flutter/material.dart';

import '../nav.dart';
import '../theme.dart';

/// 제목 + (선택) 뒤로 가기 버튼 앱바
class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleAppBar({
    super.key,
    required this.title,
    this.back = true,
    this.center = false,
    this.titleSize,
    this.actions,
  });

  final String title;
  final bool back;
  final bool center;

  /// null이면 앱바 기본 크기
  final double? titleSize;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    centerTitle: center,
    leading: back
        ? IconButton(
            key: const Key('back'),
            onPressed: () => context.back(),
            icon: const Icon(Icons.arrow_back, color: AppColor.white),
          )
        : null,
    title: Text(title, style: AppText.title.copyWith(fontSize: titleSize)),
    actions: actions,
  );
}
