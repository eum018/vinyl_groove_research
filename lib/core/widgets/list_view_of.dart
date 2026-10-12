import 'package:flutter/material.dart';

import '../list_controller.dart';
import 'empty_state.dart';
import 'ui_state_view.dart';

/// ListController를 듣고 네 가지 상태를 그린다. 목록 화면은 data만 넘긴다.
class ListViewOf<T> extends StatelessWidget {
  const ListViewOf({
    super.key,
    required this.controller,
    required this.data,
    this.empty = const EmptyState(title: '결과가 없습니다.'),
  });

  final ListController<T> controller;
  final Widget Function(List<T> items) data;
  final Widget empty;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => UiStateView(
      state: controller.state,
      data: data,
      empty: empty,
      onRetry: controller.refresh,
    ),
  );
}
