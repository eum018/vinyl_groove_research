import 'package:flutter/foundation.dart';

import '../auth_repository.dart';

/// PIN 간편 로그인. 규칙과 문구는 여기 한 곳 — 화면 3개는 결과만 보여준다.
class PinStore extends ChangeNotifier {
  PinStore(this._repo) : _saved = _repo.loadPin();

  static const _mismatch = 'PIN 번호가 다릅니다.\n4자리 PIN 번호를 다시 입력해주세요.';

  final AuthRepository _repo;
  List<int>? _saved;
  List<int>? _draft;

  /// 1단계 설정. null이면 통과.
  String? draft(List<int> pin) {
    if (pin.toSet().length == 1) return 'PIN번호는 동일 숫자 4자리를 입력할 수 없습니다.';
    _draft = pin;
    return null;
  }

  /// 2단계 재확인. 맞으면 저장한다 (앱을 껐다 켜도 남는다).
  Future<String?> confirm(List<int> pin) async {
    if (!listEquals(pin, _draft)) return _mismatch;
    _saved = pin;
    await _repo.savePin(pin);
    notifyListeners();
    return null;
  }

  String? verify(List<int> pin) => listEquals(pin, _saved) ? null : _mismatch;

  Future<void> clear() async {
    _saved = null;
    _draft = null;
    notifyListeners();
    await _repo.clearPin();
  }
}
