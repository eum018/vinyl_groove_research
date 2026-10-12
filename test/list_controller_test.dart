import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinyl_groove/core/api_client.dart';
import 'package:vinyl_groove/core/list_controller.dart';
import 'package:vinyl_groove/core/ui_state.dart';

void main() {
  test('실패와 결과 0개를 구분한다', () async {
    final failing = ListController<int>((_) async => const Err('서버 통신 에러'));
    await failing.refresh();
    expect(failing.state, isA<Failure<List<int>>>());

    final empty = ListController<int>((_) async => const Ok([]));
    await empty.refresh();
    expect(empty.state, isA<Empty<List<int>>>());
  });

  test('늦게 온 응답은 버린다 (_seq)', () async {
    final slow = Completer<Result<List<String>>>();
    final fast = Completer<Result<List<String>>>();
    var call = 0;
    final c = ListController<String>((_) => (call++ == 0 ? slow : fast).future);

    final first = c.refresh(); // Rock
    final second = c.refresh(); // Jazz
    fast.complete(const Ok(['Jazz']));
    await second;
    slow.complete(const Ok(['Rock'])); // 먼저 보냈지만 늦게 도착
    await first;

    expect(c.items, ['Jazz']);
  });

  test('페이지는 성공했을 때만 올라간다', () async {
    final asked = <int>[];
    var fail = false;
    final c = ListController<int>((page) async {
      asked.add(page);
      if (fail) return const Err('끊김');
      return Ok([page], meta: {'hasNext': true});
    });

    await c.refresh(); // 1페이지
    fail = true;
    c.more(); // 2페이지 실패
    await Future<void>.delayed(Duration.zero);
    fail = false;
    c.more(); // 다시 2페이지
    await Future<void>.delayed(Duration.zero);

    expect(asked, [1, 2, 2]);
    expect(c.items, [1, 2]);
  });
}
