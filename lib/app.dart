import 'package:flutter/material.dart';

import 'core/nav.dart';
import 'presentation/album/album_screen.dart';
import 'presentation/album/my_regi_screen.dart';
import 'presentation/album/regi_screen.dart';
import 'presentation/alert/alerts_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/signup_screen.dart';
import 'presentation/barcode/barcode_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/like/like_screen.dart';
import 'presentation/my/fingerprint_screen.dart';
import 'presentation/my/my_screen.dart';
import 'presentation/my/pin_login_screen.dart';
import 'presentation/my/pin_screen.dart';
import 'presentation/nav_screen.dart';
import 'presentation/search/search_screen.dart';

/// 화면 이름 → 화면. 화면끼리는 서로를 모르고, 여기만 전부를 안다.
class VinylGrooveApp extends StatelessWidget {
  const VinylGrooveApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Vinyl Groove',
    routes: {
      Routes.login: (_) => const LoginScreen(),
      Routes.signup: (_) => const SignupScreen(),
      Routes.nav: (_) => NavScreen(pageOf: _tabPage),
      Routes.album: (c) =>
          AlbumScreen(id: ModalRoute.settingsOf(c)!.arguments! as int),
      Routes.regi: (_) => const RegiScreen(),
      Routes.myRegi: (_) => const MyRegiScreen(),
      Routes.alerts: (_) => const AlertsScreen(),
      Routes.barcode: (_) => const BarcodeScreen(),
      Routes.pinSetup: (_) => const PinScreen(),
      Routes.pinCheck: (_) => const PinCheckScreen(),
      Routes.pinLogin: (_) => const PinLoginScreen(),
      Routes.fingerprint: (_) => const FingerprintScreen(),
    },
  );

  // 탭을 옮길 때마다 화면을 새로 만든다. 탐색 필터는 SearchStore에 있어서 남는다.
  static Widget _tabPage(NavTab tab, NavActions nav) => switch (tab) {
    NavTab.home => HomeScreen(onOpenSearch: nav.openSearch),
    NavTab.search => SearchScreen(initialGenre: nav.genre),
    NavTab.like => const LikeScreen(),
    NavTab.my || NavTab.add => const MyScreen(),
  };
}
