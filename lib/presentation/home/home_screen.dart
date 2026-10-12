import 'package:flutter/material.dart';

import '../../core/app_icon.dart';
import '../../core/list_controller.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_view_of.dart';
import '../../core/widgets/more_button.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../widgets/album_card.dart';
import '../widgets/barcode_button.dart';
import '../widgets/home_app_bar.dart';
import 'genre_grid.dart';
import 'recode_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenSearch});

  /// 탐색 탭으로 (장르를 주면 그 장르만 골라서)
  final void Function([Genre? genre]) onOpenSearch;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: Sort.values.length, vsync: this);
  late final _products = context.deps.products;
  var _sort = Sort.popular;

  late final _picks = ListController<AlbumModel>(
    (_) => _products.bySort(Sort.popular, limit: 5),
  );
  late final _list = ListController<AlbumModel>(
    (_) => _products.bySort(_sort, limit: 10),
  );

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() => Future.wait([_picks.refresh(), _list.refresh()]);

  @override
  void dispose() {
    _tabs.dispose();
    _picks.dispose();
    _list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: const HomeAppBar(),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Gap.l,
                children: [
                  AppTextField(
                    key: const Key('home_search'),
                    hint: '앨범명, 아티스트 검색',
                    icon: AppIcon.search,
                    suffix: const BarcodeButton(),
                    onTap: widget.onOpenSearch,
                  ),
                  RecodeWidget(controller: _picks),
                  _Header(
                    AppText.bold(18).text('장르별 둘러보기'),
                    widget.onOpenSearch,
                  ),
                  GenreGrid(onTap: widget.onOpenSearch),
                  _Header(_SortTabs(_tabs, _onSort), () {}),
                ],
              ),
            ),
            SizedBox(
              height: 260,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Gap.xl),
                child: ListViewOf(
                  controller: _list,
                  empty: const EmptyState(title: '등록된 상품이 없습니다.'),
                  data: (albums) => _AlbumRow(albums),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _onSort(int i) {
    _sort = Sort.values[i];
    _list.refresh();
  }
}

/// 왼쪽 제목(또는 탭) + 오른쪽 "전체 보기"
class _Header extends StatelessWidget {
  const _Header(this.left, this.onMore);

  final Widget left;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: left),
      MoreButton(onPressed: onMore),
    ],
  );
}

class _SortTabs extends StatelessWidget {
  const _SortTabs(this.controller, this.onTap);

  final TabController controller;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => TabBar(
    controller: controller,
    isScrollable: true,
    indicatorColor: AppColor.yellow,
    dividerHeight: 0,
    tabAlignment: TabAlignment.start,
    labelColor: AppColor.white,
    unselectedLabelColor: AppColor.whiteL1,
    padding: EdgeInsets.zero,
    labelPadding: const EdgeInsets.symmetric(horizontal: Gap.s),
    onTap: onTap,
    tabs: [for (final s in Sort.values) Tab(text: s.label)],
  );
}

class _AlbumRow extends StatelessWidget {
  const _AlbumRow(this.albums);

  final List<AlbumModel> albums;

  @override
  Widget build(BuildContext context) => ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: Gap.l),
    itemCount: albums.length,
    itemBuilder: (context, i) =>
        AlbumCard(key: ValueKey(albums[i].id), album: albums[i]),
    separatorBuilder: (context, i) => const SizedBox(width: Gap.m),
  );
}
