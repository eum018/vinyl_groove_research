import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/list_controller.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets/list_view_of.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/album_thumb.dart';
import '../../core/widgets/trailing_arrow.dart';
import '../../domain/models.dart';

/// "오늘의 추천 바이닐" — 턴테이블 위 음반. 톤암을 내리면 돈다.
class RecodeWidget extends StatelessWidget {
  const RecodeWidget({super.key, required this.controller});

  final ListController<AlbumModel> controller;

  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      children: [
        const _Title(),
        ListViewOf(
          controller: controller,
          empty: const SizedBox(height: 332), // 비어도 자리 높이는 그대로
          data: (albums) => _Player(albums),
        ),
      ],
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) => Column(
    spacing: Gap.xs,
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.blackL2,
          foregroundColor: AppColor.yellow,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          side: const BorderSide(color: AppColor.yellow),
        ),
        onPressed: () {},
        child: AppText.bold(12, null).text('오늘의 추천 바이닐'),
      ),
      AppText.bold(24).text('오늘, 이 바이닐은\n어떠세요?', align: TextAlign.center),
      AppText.regular(
        12,
        AppColor.whiteL3,
      ).text('매일 새롭게 선별한 특별한 한 장', align: TextAlign.center),
    ],
  );
}

class _Player extends StatefulWidget {
  const _Player(this.albums);

  final List<AlbumModel> albums;

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> with SingleTickerProviderStateMixin {
  static const _up = pi / 8; // 톤암이 올라간 각도

  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  int _page = 0;
  double _angle = _up;

  void _onPage(int v) => setState(() {
    _page = v;
    _spin.stop();
    _angle = _up;
  });

  void _onDrag(double dy) =>
      setState(() => _angle = (_angle - dy * .01).clamp(-_up, _up));

  // 톤암을 판 위로 내리면 돌고, 올리면 멈춘다
  void _onDrop() =>
      setState(() => _angle < pi / 16 ? _spin.repeat() : _spin.stop());

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.l),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _spin.isAnimating ? 380 : 300,
          curve: Curves.easeInOutCubic,
          child: PageView(
            onPageChanged: _onPage,
            children: [
              for (final a in widget.albums)
                _Page(a, _spin, _angle, _onDrag, _onDrop),
            ],
          ),
        ),
      ),
      _Dots(count: widget.albums.length, page: _page),
    ],
  );
}

/// 추천 한 장: 턴테이블 + 아래 앨범 정보
class _Page extends StatelessWidget {
  const _Page(this.album, this.spin, this.angle, this.onDrag, this.onDrop);

  final AlbumModel album;
  final AnimationController spin;
  final double angle;
  final ValueChanged<double> onDrag;
  final VoidCallback onDrop;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      children: [
        _Turntable(album, spin, angle, onDrag, onDrop),
        _NowPlaying(album: album, playing: spin.isAnimating),
      ],
    ),
  );
}

class _Turntable extends StatelessWidget {
  const _Turntable(this.album, this.spin, this.angle, this.onDrag, this.onDrop);

  final AlbumModel album;
  final Animation<double> spin;
  final double angle;
  final ValueChanged<double> onDrag;
  final VoidCallback onDrop;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onVerticalDragUpdate: (d) => onDrag(d.delta.dy),
    onVerticalDragEnd: (_) => onDrop(),
    child: Stack(
      children: [
        Center(
          child: Image.asset(
            'assets/turntable.png',
            width: 300,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(-.1, -.1),
            child: _Vinyl(image: album.albumImage, spin: spin),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(.7, -.9),
            child: Transform.rotate(
              angle: angle,
              alignment: const Alignment(.6, 0),
              child: Image.asset(
                'assets/tonearm.png',
                fit: BoxFit.cover,
                width: 180,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Vinyl extends StatelessWidget {
  const _Vinyl({required this.image, required this.spin});

  final String image;
  final Animation<double> spin;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: spin,
    builder: (context, child) =>
        Transform.rotate(angle: spin.value * pi * 2, child: child),
    child: Container(
      width: 210,
      height: 210,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/vinyl.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: CircleAvatar(
        radius: 42,
        backgroundImage: NetworkImage(image),
        onBackgroundImageError: (_, _) {},
      ),
    ),
  );
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying({required this.album, required this.playing});

  final AlbumModel album;
  final bool playing;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: playing ? 1 : .2,
    curve: Curves.easeInOutCubic,
    child: Material(
      clipBehavior: Clip.hardEdge,
      shape: AppStyle.panel,
      color: AppColor.blackL2,
      child: InkWell(
        onTap: () => context.go(Routes.album, album.id),
        child: Row(
          spacing: Gap.m,
          children: [
            AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              offset: playing ? Offset.zero : const Offset(0, -.8),
              child: AlbumThumb(album.albumImage, size: 64),
            ),
            Expanded(child: _AlbumText(album)),
            const TrailingArrow(),
          ],
        ),
      ),
    ),
  );
}

class _AlbumText extends StatelessWidget {
  const _AlbumText(this.album);

  final AlbumModel album;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.xs,
    children: [
      AppText.bold(15).text(album.albumName, overflow: TextOverflow.ellipsis),
      AppText.regular(
        14,
        AppColor.yellow,
      ).text(album.artist, overflow: TextOverflow.ellipsis),
      AppText.regular(12, AppColor.whiteL3).text(
        '${album.genre.label} • ${album.condition.code}',
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.page});

  final int count;
  final int page;

  @override
  Widget build(BuildContext context) => Row(
    spacing: Gap.s,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: i == page ? AppColor.yellow : AppColor.whiteL4,
            borderRadius: BorderRadius.circular(99),
          ),
          height: 8,
          width: i == page ? 20 : 8,
        ),
    ],
  );
}
