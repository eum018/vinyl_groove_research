import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinyl_groove/core/api_client.dart';
import 'package:vinyl_groove/core/scope.dart';
import 'package:vinyl_groove/core/widgets/pin_page.dart';
import 'package:vinyl_groove/data/fake_repositories.dart';
import 'package:vinyl_groove/domain/models.dart';
import 'package:vinyl_groove/domain/search_filter.dart';
import 'package:vinyl_groove/presentation/search/search_screen.dart';

Widget _app(Deps deps, Widget home) => AppScope(
  deps: deps,
  child: MaterialApp(home: home),
);

void main() {
  // 토스트는 안드로이드 쪽 기능이라 테스트에서는 받아만 둔다
  final toasts = <String?>[];
  setUp(() {
    toasts.clear();
    // 폰 크기 화면 (Pixel 9 정도)
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 2.625;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.example.vinyl_groove_m'),
          (call) async => toasts.add(call.arguments['m'] as String?),
        );
  });

  testWidgets('서버 없이 가짜 Repository로 탐색 화면이 뜬다', (t) async {
    await t.pumpWidget(_app(Deps.fake(), const SearchScreen()));
    await t.pumpAndSettle();

    expect(find.text('검색 결과 3개'), findsOneWidget);
    for (final a in sampleAlbums) {
      expect(find.byKey(ValueKey(a.id)), findsOneWidget);
    }
  });

  testWidgets('서버가 실패하면 스피너가 아니라 안내와 다시 시도 버튼이 뜬다', (t) async {
    await t.pumpWidget(
      _app(Deps.fake(products: _FailingProducts()), const SearchScreen()),
    );
    await t.pumpAndSettle();

    expect(find.text('서버 통신 에러'), findsOneWidget);
    expect(find.byKey(const Key('retry')), findsOneWidget);
  });

  testWidgets('PIN을 틀리면 입력 4칸이 비워져 바로 다시 칠 수 있다', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: PinPage(
          title: 'PIN',
          message: '입력',
          check: (pin) async => '틀렸습니다',
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await t.tap(find.byKey(const Key('pin_key_1')));
      await t.pump();
    }
    await t.pumpAndSettle();

    expect(find.text('틀렸습니다'), findsOneWidget);
    expect(find.text('*'), findsNothing); // 4칸이 다 비었다
    await t.tap(find.byKey(const Key('pin_key_1')));
    await t.pump();
    // 바로 다시 입력된다 — 첫 칸에 방금 누른 숫자가 보인다
    expect(
      find.descendant(
        of: find.byKey(const Key('pin_slot_0')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  test('로그아웃하면 관심상품·PIN·로그인 정보가 전부 지워진다', () async {
    final deps = Deps.fake();
    await deps.session.login('a@test.com', 'Abcdef');
    await deps.likes.toggle(sampleAlbums.first);
    deps.pins.draft([1, 2, 3, 4]);
    await deps.pins.confirm([1, 2, 3, 4]);

    await deps.logout();

    expect(deps.session.token, isNull);
    expect(deps.likes.items, isEmpty);
    expect(deps.pins.verify([1, 2, 3, 4]), isNotNull);
  });
}

class _FailingProducts extends FakeProductRepository {
  @override
  Future<Result<List<AlbumModel>>> search(SearchFilter f, int page) async =>
      const Err('서버 통신 에러');
}
