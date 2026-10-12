import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_repository.dart';
import '../data/fake_repositories.dart';
import '../data/notification_repository.dart';
import '../data/product_repository.dart';
import '../data/stores/alert_store.dart';
import '../data/stores/like_store.dart';
import '../data/stores/pin_store.dart';
import '../data/stores/search_store.dart';
import '../data/stores/session_store.dart';
import 'api_client.dart';

/// 앱이 쓰는 Repository·Store 한 벌. 진짜(production)와 가짜(fake)를 바꿔 끼운다.
class Deps {
  Deps({
    required this.auth,
    required this.products,
    required this.notifications,
    required this.session,
    required this.likes,
    this.cameras = const [],
  }) : alerts = AlertStore(notifications),
       pins = PinStore(auth),
       search = SearchStore(products);

  static Future<Deps> production(List<CameraDescription> cameras) async {
    final prefs = await SharedPreferences.getInstance();
    late final SessionStore session;
    final api = ApiClient(token: () => session.token);
    final auth = HttpAuthRepository(api, prefs);
    final products = HttpProductRepository(api, prefs);
    session = SessionStore(auth);

    final restored = await products.restoreLikes();
    return Deps(
      auth: auth,
      products: products,
      notifications: HttpNotificationRepository(api),
      session: session,
      likes: LikeStore(products, switch (restored) {
        Ok(:final value) => value,
        Err() => const [],
      }),
      cameras: cameras,
    );
  }

  factory Deps.fake({FakeProductRepository? products}) {
    final auth = FakeAuthRepository();
    final repo = products ?? FakeProductRepository();
    return Deps(
      auth: auth,
      products: repo,
      notifications: FakeNotificationRepository(),
      session: SessionStore(auth),
      likes: LikeStore(repo, const []),
    );
  }

  final AuthRepository auth;
  final ProductRepository products;
  final NotificationRepository notifications;
  final List<CameraDescription> cameras;

  final SessionStore session;
  final LikeStore likes;
  final AlertStore alerts;
  final PinStore pins;
  final SearchStore search;

  /// 로그아웃 = 로그인한 사람의 데이터를 전부 비운다. 새 Store가 생기면 여기에 한 줄.
  Future<void> logout() async {
    session.clear();
    alerts.clear();
    search.clear();
    await likes.clear();
    await pins.clear();
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.deps, required super.child});

  final Deps deps;

  static Deps of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.deps;

  @override
  bool updateShouldNotify(AppScope oldWidget) => deps != oldWidget.deps;
}

extension DepsOf on BuildContext {
  Deps get deps => AppScope.of(this);
}
