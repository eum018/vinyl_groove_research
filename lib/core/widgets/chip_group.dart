import 'package:flutter/material.dart';

import 'filter_button.dart';

/// "전체" 버튼(선택) + 항목 칩 묶음. 탐색 필터 줄과 상품 등록 선택지가 같이 쓴다.
class ChipGroup<T> extends StatelessWidget {
  const ChipGroup({
    super.key,
    required this.items,
    required this.labelOf,
    required this.isSelected,
    required this.onTap,
    this.onAll,
    this.allSelected = false,
    this.wrap = false,
    this.fontSize = 12,
  });

  final List<T> items;
  final String Function(T) labelOf;
  final bool Function(T) isSelected;
  final ValueChanged<T> onTap;

  /// null이면 "전체" 버튼이 없다
  final VoidCallback? onAll;
  final bool allSelected;

  /// true면 여러 줄로 감싸고, false면 옆으로 스크롤
  final bool wrap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final chips = [
      if (onAll case final all?)
        FilterButton(
          key: const ValueKey('all'),
          label: '전체',
          selected: allSelected,
          onPressed: all,
        ),
      for (final e in items)
        FilterButton(
          key: ValueKey(e),
          label: labelOf(e),
          selected: isSelected(e),
          onPressed: () => onTap(e),
          fontSize: fontSize,
        ),
    ];
    if (wrap) {
      return SizedBox(
        width: double.infinity,
        child: Wrap(spacing: 6, runSpacing: 6, children: chips),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(spacing: 6, children: chips),
    );
  }
}
