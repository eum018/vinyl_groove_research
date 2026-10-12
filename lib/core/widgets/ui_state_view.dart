import 'package:flutter/material.dart';

import '../ui_state.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'loading_view.dart';

/// UiState 네 가지를 화면으로. switch는 여기 한 곳에만 있다.
class UiStateView<T> extends StatelessWidget {
  const UiStateView({
    super.key,
    required this.state,
    required this.data,
    required this.onRetry,
    this.empty = const EmptyState(title: '결과가 없습니다.'),
  });

  final UiState<T> state;
  final Widget Function(T value) data;
  final VoidCallback onRetry;
  final Widget empty;

  @override
  Widget build(BuildContext context) => switch (state) {
    Loading() => const LoadingView(),
    Empty() => empty,
    Failure(:final message) => ErrorState(message: message, onRetry: onRetry),
    Data(:final value) => data(value),
  };
}
