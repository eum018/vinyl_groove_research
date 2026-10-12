import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'ui_state.dart';

typedef PageFetch<T> = Future<Result<List<T>>> Function(int page);

/// 목록 화면의 로딩·빈 목록·실패·데이터 한 벌.
class ListController<T> extends ChangeNotifier {
  ListController(this._fetch);

  final PageFetch<T> _fetch;

  UiState<List<T>> state = const Loading();
  int total = 0;
  bool hasNext = false;

  int _page = 0;
  int _seq = 0;
  bool _busy = false;
  Timer? _debounce;

  List<T> get items => switch (state) {
    Data(:final value) => value,
    _ => const [],
  };

  /// 처음부터 다시. 검색어 입력처럼 연달아 오면 debounce: true
  Future<void> refresh({bool debounce = false}) async {
    _debounce?.cancel();
    if (!debounce) return _load();
    _busy = true; // 기다리는 동안 다음 페이지를 부르지 않는다
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  /// 로그아웃 때 — 처음 상태로
  void reset() {
    _debounce?.cancel();
    _seq++;
    _busy = false;
    state = const Loading();
    total = 0;
    hasNext = false;
    notifyListeners();
  }

  /// 다음 페이지. 요청 중이거나 더 없으면 부르지 않는다.
  void more() {
    if (_busy || !hasNext) return;
    _load(append: true);
  }

  Future<void> _load({bool append = false}) async {
    final seq = ++_seq;
    _busy = true;
    if (!append && state is! Data) {
      state = const Loading(); // 보이던 목록은 새 결과가 올 때까지 그대로 둔다
      notifyListeners();
    }

    final res = await _fetch(append ? _page + 1 : 1);
    if (seq != _seq) return; // 더 새 요청이 있었다 → 늦게 온 응답은 버린다
    _busy = false;

    switch (res) {
      case Err(:final message):
        if (!append) state = Failure(message); // 더 불러오기 실패는 있던 목록을 지키고 넘어간다
      case Ok(:final value, :final meta):
        _page = append ? _page + 1 : 1; // 성공했을 때만 페이지를 올린다
        hasNext = meta['hasNext'] == true;
        total = meta['total'] is int ? meta['total'] as int : value.length;
        final all = append ? [...items, ...value] : value;
        state = all.isEmpty ? const Empty() : Data(all);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _seq++; // 화면이 닫힌 뒤 도착한 응답도 버린다
    super.dispose();
  }
}
