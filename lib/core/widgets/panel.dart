import 'package:flutter/material.dart';

import '../theme.dart';

/// 둥근 회색 판 (프로필·판매자·가격 상자)
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = Gap.l});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => Material(
    shape: AppStyle.panel,
    color: AppColor.blackL2,
    child: Padding(padding: EdgeInsets.all(padding), child: child),
  );
}
