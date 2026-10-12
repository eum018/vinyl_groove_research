import 'package:flutter/material.dart';

import '../theme.dart';

/// 칩 하나. 고르면 노란색.
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.fontSize = 12,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: AppStyle.chip(selected),
    onPressed: onPressed,
    child: Text(label, style: AppText.bold(fontSize, null)),
  );
}
