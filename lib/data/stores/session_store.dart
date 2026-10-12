import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import '../../domain/models.dart';
import '../auth_repository.dart';

/// 로그인 정보. 로그인부터 로그아웃까지 산다.
class SessionStore extends ChangeNotifier {
  SessionStore(this._repo);

  final AuthRepository _repo;

  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;

  Future<Result<Session>> login(String email, String password) async {
    final res = await _repo.login(email, password);
    if (res case Ok(:final value)) {
      _token = value.token;
      _user = value.user;
      notifyListeners();
    }
    return res;
  }

  void clear() {
    _token = null;
    _user = null;
    notifyListeners();
  }
}
