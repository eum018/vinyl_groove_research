import 'package:flutter/material.dart';

import '../theme.dart';

/// 가로 카드 줄. 왼쪽으로 천천히 흘러가고, 끝에 닿으면 처음으로 돌아간다.
class AutoScrollRow extends StatefulWidget {
  const AutoScrollRow({super.key, required this.children});

  final List<Widget> children;

  @override
  State<AutoScrollRow> createState() => _AutoScrollRowState();
}

class _AutoScrollRowState extends State<AutoScrollRow> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    while (mounted && _scroll.hasClients) {
      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) return; // 화면에 다 보이면 움직일 필요가 없다
      await _scroll.animateTo(
        max,
        duration: Duration(milliseconds: (max * 20).round()),
        curve: Curves.linear,
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    controller: _scroll,
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: Gap.l),
    child: Row(spacing: Gap.m, children: widget.children),
  );
}
