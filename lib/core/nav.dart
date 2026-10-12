import 'package:flutter/widgets.dart';

/// 화면 이름. 화면 파일은 다른 화면 파일을 import하지 않고 이 이름으로 이동한다.
/// 이름 → 화면 연결은 lib/app.dart 한 곳에 있다.
abstract final class Routes {
  static const login = '/'; // 첫 화면
  static const signup = '/signup';
  static const nav = '/main';
  static const album = '/album'; // arguments: int id
  static const regi = '/regi';
  static const myRegi = '/my-regi';
  static const alerts = '/alerts';
  static const barcode = '/barcode';
  static const pinSetup = '/pin';
  static const pinCheck = '/pin/check';
  static const pinLogin = '/pin/login';
  static const fingerprint = '/fingerprint';
}

extension Nav on BuildContext {
  Future<T?> go<T>(String route, [Object? args]) =>
      Navigator.pushNamed<T>(this, route, arguments: args);

  Future<T?> re<T>(String route, [Object? args]) =>
      Navigator.pushReplacementNamed<T, Object?>(this, route, arguments: args);

  /// 뒤로 가기로 돌아올 화면을 전부 지운다 (로그인 성공·로그아웃)
  Future<T?> reset<T>(String route) =>
      Navigator.pushNamedAndRemoveUntil<T>(this, route, (_) => false);

  void back<T>([T? result]) => Navigator.pop<T>(this, result);
}
