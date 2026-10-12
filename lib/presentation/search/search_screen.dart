import 'package:flutter/material.dart';

import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_view_of.dart';
import '../../data/stores/search_store.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../widgets/album_card.dart';
import '../widgets/barcode_button.dart';
import '../widgets/home_app_bar.dart';
import 'search_filter_panel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialGenre});

  /// 홈에서 장르를 눌러 들어왔을 때 그 장르
  final Genre? initialGenre;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchStore _store = context.deps.search;
  late final _keyword = TextEditingController(text: _store.filter.keyword);
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final p = _scroll.position;
      if (p.pixels >= p.maxScrollExtent) _store.list.more(); // 끝까지 내리면 다음 페이지
    });
    // 첫 프레임을 그린 뒤 조회한다 (그리는 도중에 다른 화면을 다시 그리게 하지 않으려고)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (widget.initialGenre) {
        case final g?:
          _store.onlyGenre(g);
        case null:
          _store.list.refresh();
      }
    });
  }

  @override
  void dispose() {
    _keyword.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: const HomeAppBar(),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Gap.l,
              children: [
                _KeywordField(_keyword, _store),
                SearchFilterPanel(store: _store),
              ],
            ),
          ),
          const Divider(color: AppColor.blackL1, height: 1),
          const Divider(color: AppColor.blackL2, height: 1),
          Expanded(child: _Results(_store, _scroll)),
        ],
      ),
    ),
  );
}

/// 검색어 입력. 글자가 있으면 X, 없으면 바코드 버튼
class _KeywordField extends StatelessWidget {
  const _KeywordField(this.controller, this.store);

  final TextEditingController controller;
  final SearchStore store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => AppTextField(
      key: const Key('search_keyword'),
      controller: controller,
      hint: '앨범명, 아티스트',
      onChanged: store.keyword,
      suffix: controller.text.isEmpty
          ? const BarcodeButton()
          : IconButton(
              key: const Key('search_clear'),
              onPressed: () {
                controller.clear();
                store.clearKeyword();
              },
              icon: const Icon(Icons.close, color: AppColor.white),
            ),
    ),
  );
}

/// 결과 개수·정렬 + 결과 격자
class _Results extends StatelessWidget {
  const _Results(this.store, this.scroll);

  final SearchStore store;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Gap.l),
    child: Column(
      spacing: Gap.xl,
      children: [
        _ResultHeader(store),
        Expanded(
          child: ListViewOf(
            controller: store.list,
            empty: const EmptyState(title: '검색 결과가 없습니다.'),
            data: (albums) => _ResultGrid(albums, scroll),
          ),
        ),
      ],
    ),
  );
}

/// "검색 결과 N개" + 정렬 메뉴
class _ResultHeader extends StatelessWidget {
  const _ResultHeader(this.store);

  final SearchStore store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([store, store.list]),
    builder: (context, _) => Row(
      children: [
        AppText.bold(18).text('검색 결과 ${store.list.total}개'),
        const Spacer(),
        PopupMenuButton<Sort>(
          key: const Key('search_sort'),
          color: AppColor.blackL2,
          onSelected: store.sortBy,
          itemBuilder: (context) => [
            for (final s in Sort.menuOrder)
              PopupMenuItem(
                value: s,
                child: AppText.regular(14, AppColor.whiteL1).text(s.menuLabel),
              ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.medium(
                12,
                AppColor.whiteL1,
              ).text(store.filter.sort.menuLabel),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColor.whiteL1,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ResultGrid extends StatelessWidget {
  const _ResultGrid(this.albums, this.scroll);

  final List<AlbumModel> albums;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) => GridView.builder(
    controller: scroll,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisExtent: 210,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
    ),
    itemCount: albums.length,
    itemBuilder: (context, i) =>
        AlbumCard(key: ValueKey(albums[i].id), album: albums[i], size: 11),
  );
}
