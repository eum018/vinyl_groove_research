import 'package:flutter/material.dart';

import '../theme.dart';

/// 입력 항목 하나: 이름 + 입력 부품 + 에러 문구
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.label,
    required this.child,
    this.star = false,
    this.bold = false,
    this.error,
    this.errorSize = 14,
    this.note,
    this.noteSize = 12,
  });

  final String label;
  final Widget child;

  /// 이름 뒤에 빨간 " *"
  final bool star;
  final bool bold;
  final String? error;
  final double errorSize;

  /// 입력 부품 아래 회색 설명 (예: 비밀번호 규칙)
  final String? note;
  final double noteSize;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.s,
    children: [
      Row(
        children: [
          (bold ? AppText.bold(14) : AppText.medium(14)).text(label),
          if (star) AppText.medium(14, AppColor.red).text(' *'),
        ],
      ),
      child,
      if (note case final n?)
        AppText.regular(noteSize, AppColor.whiteL1).text(n),
      if (error case final e?) AppText.regular(errorSize, AppColor.red).text(e),
    ],
  );
}
