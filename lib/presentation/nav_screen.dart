import 'package:flutter/material.dart';

import '../core/app_icon.dart';
import '../core/nav.dart';
import '../core/scope.dart';
import '../core/theme.dart';
import '../data/stores/alert_store.dart';
import '../domain/enums.dart';

/// 탭 화면이 NavScreen에 부탁할 수 있는 것
class NavActions {
  const NavActions({required this.openSearch, this.genre});

  /// 탐색 탭으로 (장르를 주면 그 장르만 골라서)
  final void Function([Genre? genre]) openSearch;

  /// 홈에서 고른 장르. 탐색 화면을 처음 만들 때 한 번만 쓴다.
  final Genre? genre;
}

enum NavTab {
  home(AppIcon.home, '홈'),
  search(AppIcon.search, '탐색'),
  add(AppIcon.add, ''), // 가운데 + 버튼: 탭이 아니라 상품 등록으로 간다
  like(AppIcon.heart, '관심상품'),
  my(AppIcon.mypage, '마이페이지');

  const NavTab(this.icon, this.label);

  final AppIcon icon;
  final String label;
}

/// 아래 탭 틀. 어떤 탭에 어떤 화면을 넣을지는 lib/app.dart가 정한다.
class NavScreen extends StatefulWidget {
  const NavScreen({super.key, required this.pageOf});

  final Widget Function(NavTab tab, NavActions actions) pageOf;

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  late final AlertStore _alerts = context.deps.alerts;
  var _tab = NavTab.home; // 탭 위치는 이 화면만 알면 된다
  Genre? _genre;

  @override
  void initState() {
    super.initState();
    _alerts.startPolling();
  }

  @override
  void dispose() {
    _alerts.stopPolling();
    super.dispose();
  }

  void _select(NavTab tab, [Genre? genre]) {
    if (tab == NavTab.add) {
      context.go(Routes.regi);
      return;
    }
    setState(() {
      _tab = tab;
      _genre = genre;
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      bottomNavigationBar: _BottomBar(current: _tab, onTap: (t) => _select(t)),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: widget.pageOf(
        _tab,
        NavActions(
          openSearch: ([g]) => _select(NavTab.search, g),
          genre: _genre,
        ),
      ),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.current, required this.onTap});

  final NavTab current;
  final ValueChanged<NavTab> onTap;

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    key: const Key('bottom_nav'),
    backgroundColor: AppColor.blackL2,
    currentIndex: current.index,
    selectedItemColor: AppColor.yellow,
    unselectedItemColor: AppColor.whiteL1,
    type: BottomNavigationBarType.fixed,
    onTap: (i) => onTap(NavTab.values[i]),
    items: [
      for (final t in NavTab.values)
        BottomNavigationBarItem(
          label: t.label,
          icon: t == NavTab.add
              ? const CircleAvatar(
                  backgroundColor: AppColor.yellow,
                  radius: 28,
                  child: Icon(Icons.add, color: AppColor.black),
                )
              : t.icon.icon(
                  color: t == current ? AppColor.yellow : AppColor.whiteL1,
                ),
        ),
    ],
  );
}
