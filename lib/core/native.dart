import 'package:flutter/services.dart';

/// 안드로이드 쪽(MainActivity.kt)과 이야기하는 곳은 이 파일 하나.
abstract final class Native {
  static const _channel = MethodChannel('com.example.vinyl_groove_m');

  static Future<void> toast(String? m) =>
      _channel.invokeMethod('t', {'m': m ?? 'error'});

  static Future<void> notReady(String feature) =>
      toast('$feature 기능은 준비중입니다.\n다음에 다시 시도해 주세요.');

  /// 바코드를 못 읽으면 null
  static Future<String?> scan(Uint8List bytes, int width, int height) =>
      _channel.invokeMethod<String>('scan', {
        'bytes': bytes,
        'width': width,
        'height': height,
      });
}
