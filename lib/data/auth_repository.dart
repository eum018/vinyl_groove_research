import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../domain/models.dart';

typedef Session = ({String token, User user});

abstract class AuthRepository {
  Future<Result<Session>> login(String email, String password);

  Future<Result<void>> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  List<int>? loadPin();
  Future<void> savePin(List<int> pin);
  Future<void> clearPin();
}

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._api, this._prefs);

  static const _pinKey = 'pin';

  final ApiClient _api;
  final SharedPreferences _prefs;

  @override
  Future<Result<Session>> login(String email, String password) async {
    final res = await _api.post('/auth/login/v2', {
      'email': email,
      'password': password,
    });
    return switch (res) {
      Ok(value: final Map value) => Ok((
        token: '${value['token']}',
        user: User.from(value['user']),
      )),
      Ok() => const Err('서버 응답을 읽을 수 없습니다.'),
      Err(:final message, :final fields) => Err(message, fields: fields),
    };
  }

  @override
  Future<Result<void>> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) => _api.post('/auth/signup', {
    'email': email,
    'password': password,
    'name': name,
    'phone': phone,
  });

  @override
  List<int>? loadPin() => _prefs
      .getStringList(_pinKey)
      ?.map(int.tryParse)
      .whereType<int>()
      .toList();

  @override
  Future<void> savePin(List<int> pin) =>
      _prefs.setStringList(_pinKey, [for (final n in pin) '$n']);

  @override
  Future<void> clearPin() => _prefs.remove(_pinKey);
}
