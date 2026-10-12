import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_icon.dart';
import '../../core/format.dart';
import '../../core/list_controller.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/condition_badge.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_view_of.dart';
import '../../core/widgets/album_thumb.dart';
import '../../core/widgets/title_app_bar.dart';
import '../../domain/models.dart';

class MyRegiScreen extends StatefulWidget {
  const MyRegiScreen({super.key});

  @override
  State<MyRegiScreen> createState() => _MyRegiScreenState();
}

class _MyRegiScreenState extends State<MyRegiScreen> {
  late final _products = context.deps.products;
  late final _list = ListController<AlbumModel>((_) => _products.mine());

  @override
  void initState() {
    super.initState();
    _list.refresh();
  }

  Future<void> _add() async {
    await context.go(Routes.regi);
    if (!mounted) return;
    _list.refresh(); // 등록하고 돌아오면 목록을 새로
  }

  Future<void> _delete(AlbumModel a) async {
    final ok = await AppConfirmDialog.show(
      context,
      title: '${a.albumName}을(를)\n삭제하시겠습니까?',
      confirm: '삭제',
    );
    if (!ok) return;
    final res = await _products.remove(a.id);
    if (!mounted) return;
    switch (res) {
      case Ok():
        Native.toast('상품이 삭제되었습니다');
        _list.refresh();
      case Err(:final message):
        Native.toast(message);
    }
  }

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: TitleAppBar(
        title: '내 등록 상품',
        actions: [
          IconButton(
            key: const Key('my_regi_add'),
            onPressed: _add,
            icon: const Icon(Icons.add, color: AppColor.white, size: 32),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: RefreshIndicator(
        onRefresh: _list.refresh,
        child: ListViewOf(
          controller: _list,
          empty: const EmptyState(
            title: '등록된 상품이 없습니다.',
            bright: true,
            scrollable: true,
          ),
          data: (albums) => ListView(
            children: [
              for (final a in albums)
                _MyAlbumTile(key: ValueKey(a.id), album: a, onDelete: _delete),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MyAlbumTile extends StatelessWidget {
  const _MyAlbumTile({super.key, required this.album, required this.onDelete});

  final AlbumModel album;
  final ValueChanged<AlbumModel> onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Gap.s),
    child: Material(
      shape: AppStyle.panel,
      clipBehavior: Clip.hardEdge,
      color: AppColor.blackL2,
      child: InkWell(
        onTap: () => context.go(Routes.album, album.id),
        child: Padding(
          padding: const EdgeInsets.all(Gap.s),
          child: Row(
            spacing: Gap.m,
            children: [
              AlbumThumb(album.albumImage, size: 82),
              Expanded(child: _AlbumText(album)),
              _Actions(
                onEdit: () => Native.notReady('앨범 수정'),
                onDelete: () => onDelete(album),
              ),
            ],
          ),
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
      AppText.bold(15).text(album.albumName),
      AppText.regular(14, AppColor.whiteL1).text(album.artist),
      Row(
        spacing: Gap.s,
        children: [
          ConditionBadge(album.condition, color: AppColor.whiteL1),
          AppText.bold(15, AppColor.yellow).text(Fmt.won(album.price)),
        ],
      ),
    ],
  );
}

/// 수정·삭제 아이콘
class _Actions extends StatelessWidget {
  const _Actions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: Gap.xs,
      children: [
        IconButton(
          style: style,
          onPressed: onEdit,
          icon: AppIcon.edit.icon(color: AppColor.whiteL1, size: Gap.xl),
        ),
        IconButton(
          key: const Key('my_regi_delete'),
          style: style,
          onPressed: onDelete,
          icon: AppIcon.delete.icon(color: AppColor.red, size: Gap.xl),
        ),
      ],
    );
  }
}
