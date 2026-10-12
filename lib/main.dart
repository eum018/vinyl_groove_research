import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  final deps = await Deps.production(await _findCameras());
  runApp(AppScope(deps: deps, child: const VinylGrooveApp()));
}

/// 카메라가 없는 기기(에뮬레이터 등)에서도 앱은 떠야 한다
Future<List<CameraDescription>> _findCameras() async {
  try {
    return await availableCameras();
  } catch (_) {
    return const [];
  }
}
