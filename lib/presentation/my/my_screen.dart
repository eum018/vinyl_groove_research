import 'package:flutter/material.dart';

import '../../core/app_icon.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets/menu_tile.dart';
import '../../core/widgets/title_app_bar.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_card.dart';

/// 메뉴 한 줄의 내용
class _Menu {
  const _Menu(this.icon, this.label, this.onTap, {this.arrow = true});

  /// 아직 없는 기능 — 누르면 "준비중" 안내
  _Menu.soon(this.icon, this.label)
    : onTap = ((_) => Native.notReady(label)),
      arrow = true;

  final AppIcon icon;
  final String label;
  final void Function(BuildContext context) onTap;
  final bool arrow;
}

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  /// 묶음 사이에 선을 긋는다
  static final _groups = [
    [
      _Menu(AppIcon.add, '상품 등록', (c) => c.go(Routes.regi), arrow: false),
      _Menu(AppIcon.inventory, '내 등록 상품', (c) => c.go(Routes.myRegi)),
    ],
    [
      _Menu.soon(AppIcon.shopping, '판매 내역'),
      _Menu.soon(AppIcon.history, '구매 내역'),
    ],
    [_Menu.soon(AppIcon.help, '고객센터'), _Menu.soon(AppIcon.info, '앱 정보')],
    [
      _Menu(AppIcon.pin, 'PIN 번호 간편 로그인', (c) => c.go(Routes.pinSetup)),
      _Menu(AppIcon.finger, '지문 인증 간편 로그인', (c) {
        Native.toast('지문 등록 기능은 구현되지 않았습니다.');
        c.go(Routes.fingerprint);
      }),
    ],
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: const TitleAppBar(title: '마이페이지', back: false),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Gap.l,
          children: [
            const ProfileCard(),
            for (final (i, group) in _groups.indexed) ...[
              if (i > 0) const Divider(color: AppColor.blackL2, height: 1),
              Column(children: [for (final m in group) _MenuRow(m)]),
            ],
            const LogoutButton(),
            const SizedBox(height: Gap.xl),
          ],
        ),
      ),
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.menu);

  final _Menu menu;

  @override
  Widget build(BuildContext context) => MenuTile(
    key: Key('menu_${menu.label}'),
    icon: menu.icon,
    label: menu.label,
    arrow: menu.arrow,
    onTap: () => menu.onTap(context),
  );
}
