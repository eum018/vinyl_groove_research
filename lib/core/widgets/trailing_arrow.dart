import 'package:flutter/material.dart';

import '../theme.dart';

/// 줄 끝의 ">" 표시
class TrailingArrow extends StatelessWidget {
  const TrailingArrow({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Gap.s),
    child: Icon(Icons.arrow_forward_ios, color: AppColor.whiteL1, size: 18),
  );
}
