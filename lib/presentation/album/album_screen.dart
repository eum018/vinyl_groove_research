import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/format.dart';
import '../../core/list_controller.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/ui_state.dart';
import '../../core/widgets/auto_scroll_row.dart';
import '../../core/widgets/condition_badge.dart';
import '../../core/widgets/filter_button.dart';
import '../../core/widgets/list_view_of.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/submit_button.dart';
import '../../core/widgets/trailing_arrow.dart';
import '../../core/widgets/ui_state_view.dart';
import '../../domain/models.dart';
import '../widgets/album_card.dart';
import '../widgets/like_button.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key, required this.id});

  final int id;

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  UiState<AlbumDetail> _detail = const Loading();
  ListController<AlbumModel>? _related;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final products = context.deps.products;
    final res = await products.detail(widget.id);
    if (!mounted) return;
    if (res case Ok(:final value)) {
      // 같은 아티스트의 다른 앨범 = 유사 앨범
      _related = ListController((_) => products.byArtist(value.album.artist))
        ..refresh();
    }
    setState(() {
      _detail = switch (res) {
        Ok(:final value) => Data(value),
        Err(:final message) => Failure(message),
      };
    });
  }

  void _retry() {
    setState(() => _detail = const Loading());
    _fetch();
  }

  @override
  void dispose() {
    _related?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: UiStateView(
        state: _detail,
        onRetry: _retry,
        data: (d) => Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _CoverBar(d.album),
                  SliverToBoxAdapter(child: _Body(d, _related!)),
                ],
              ),
            ),
            Container(
              color: AppColor.blackL2,
              padding: const EdgeInsets.all(Gap.l),
              child: SubmitButton(
                key: const Key('buy'),
                label: '구매하기',
                onPressed: () => Native.notReady('구매'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 위쪽 큰 앨범 사진 + 뒤로 가기 + 하트
class _CoverBar extends StatelessWidget {
  const _CoverBar(this.album);

  final AlbumModel album;

  @override
  Widget build(BuildContext context) => SliverAppBar(
    actions: [LikeButton(album: album, size: 28)],
    backgroundColor: Colors.transparent,
    leading: IconButton(
      key: const Key('back'),
      style: IconButton.styleFrom(backgroundColor: AppColor.dim),
      onPressed: () => context.back(),
      icon: const Icon(Icons.arrow_back, color: AppColor.white),
    ),
    expandedHeight: 300,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(album.albumImage),
          fit: BoxFit.fitWidth,
          onError: (_, _) {},
        ),
      ),
      foregroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.background, Colors.black12, Colors.black12],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body(this.d, this.related);

  final AlbumDetail d;
  final ListController<AlbumModel> related;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Gap.l),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Gap.xl,
      children: [
        _Heading(d),
        _Section(
          title: '상태 등급',
          badge: ConditionBadge(d.album.condition, fontSize: 15),
          body: d.conditionDescription,
        ),
        _Section(title: '상품 설명', body: d.description),
        _PriceBox(d.album),
        ListViewOf(
          controller: related,
          empty: const SizedBox(),
          data: (albums) => _Related(albums),
        ),
      ],
    ),
  );
}

/// "유사 앨범" + 왼쪽으로 흐르는 카드 줄
class _Related extends StatelessWidget {
  const _Related(this.albums);

  final List<AlbumModel> albums;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.xl,
    children: [
      AppText.bold(18).text('유사 앨범'),
      AutoScrollRow(
        children: [
          for (final a in albums) AlbumCard(key: ValueKey(a.id), album: a),
        ],
      ),
    ],
  );
}

/// 앨범명·아티스트, 장르·등급·거래방식 칩, 판매자
class _Heading extends StatelessWidget {
  const _Heading(this.d);

  final AlbumDetail d;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.l,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Gap.s,
        children: [
          AppText.bold(24).text(d.album.albumName),
          AppText.medium(16, AppColor.whiteL1).text(d.album.artist),
        ],
      ),
      Row(
        spacing: Gap.s,
        children: [
          for (final label in [
            d.album.genre.label,
            d.album.condition.code,
            d.album.tradeMethod.label,
          ])
            FilterButton(label: label, selected: false, onPressed: () {}),
        ],
      ),
      _Seller(d),
    ],
  );
}

class _Seller extends StatelessWidget {
  const _Seller(this.d);

  final AlbumDetail d;

  @override
  Widget build(BuildContext context) => Panel(
    child: Row(
      spacing: Gap.m,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(ApiClient.imageUrl(d.sellerImage)),
          onBackgroundImageError: (_, _) {},
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Gap.xs,
            children: [
              AppText.bold(16).text(d.sellerName),
              AppText.medium(12, AppColor.whiteL1).text(d.sellerEmail),
            ],
          ),
        ),
        const TrailingArrow(),
      ],
    ),
  );
}

/// 제목(+뱃지) + 회색 본문
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body, this.badge});

  final String title;
  final String body;
  final Widget? badge;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.s,
    children: [
      Row(spacing: Gap.s, children: [AppText.bold(18).text(title), ?badge]),
      AppText.regular(14, AppColor.whiteL1).text(body),
    ],
  );
}

class _PriceBox extends StatelessWidget {
  const _PriceBox(this.album);

  final AlbumModel album;

  @override
  Widget build(BuildContext context) => Panel(
    child: Row(
      spacing: Gap.m,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Gap.xs,
            children: [
              AppText.medium(12, AppColor.whiteL1).text('가격'),
              AppText.bold(24, AppColor.yellow).text(Fmt.won(album.price)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: Gap.xs,
          children: [
            AppText.medium(12, AppColor.whiteL1).text('거래 방식'),
            AppText.medium(18).text(album.tradeMethod.label),
          ],
        ),
      ],
    ),
  );
}
