import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/api_client.dart';
import '../../domain/models.dart';
import '../notification_repository.dart';

/// 알림 + 5초 폴링. 앱이 백그라운드로 가면 폴링을 멈춘다.
class AlertStore extends ChangeNotifier with WidgetsBindingObserver {
  AlertStore(this._repo);

  final NotificationRepository _repo;

  AlertBox _box = AlertBox.empty;
  Timer? _timer;
  int _users = 0; // 폴링을 쓰는 화면 수 (PIN 로그인 뒤 NavScreen이 두 겹일 수 있다)
  int _gen = 0; // 로그아웃 뒤 늦게 온 응답을 버리려고

  int get unreadCount => _box.unreadCount;
  List<AlertModel> get items => _box.items;

  Future<void> refresh() async {
    final gen = _gen;
    if (await _repo.fetch() case Ok(:final value) when gen == _gen) {
      _box = value;
      notifyListeners();
    }
  }

  /// 읽음 처리 뒤 목록을 다시 받는다. 결과는 화면이 안내한다.
  Future<Result<void>> read({int? id, bool all = false}) =>
      _thenRefresh(_repo.read(id: id, all: all));

  Future<Result<void>> deleteAll() => _thenRefresh(_repo.deleteAll());

  void startPolling() {
    if (_users++ > 0) return;
    WidgetsBinding.instance.addObserver(this);
    _tick();
  }

  void stopPolling() {
    if (_users == 0 || --_users > 0) return;
    _halt();
  }

  void _halt() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  void clear() {
    _users = 0;
    _halt();
    _gen++;
    _box = AlertBox.empty;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _tick() {
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => refresh());
  }

  Future<Result<void>> _thenRefresh(Future<Result<void>> job) async {
    final res = await job;
    if (res is Ok) await refresh();
    return res;
  }
}
