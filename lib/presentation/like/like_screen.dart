import 'package:flutter/material.dart';

import '../../core/app_icon.dart';
import '../../core/format.dart';
import '../../core/nav.dart';
import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../core/widgets/condition_badge.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/album_thumb.dart';
import '../../core/widgets/title_app_bar.dart';
import '../../domain/models.dart';

class LikeScreen extends StatelessWidget {
  const LikeScreen({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
    child: Scaffold(
      appBar: TitleAppBar(title: '관심 상품', back: false),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.background,
      body: _LikeList(),
    ),
  );
}

class _LikeList extends StatelessWidget {
  const _LikeList();

  @override
  Widget build(BuildContext context) {
    final likes = context.deps.likes;
    return ListenableBuilder(
      listenable: likes,
      builder: (context, _) => likes.items.isEmpty
          ? const EmptyState(
              icon: AppIcon.heart,
              title: '관심 상품이 없습니다.',
              subtitle: '마음에 드는 상품에 하트를 눌러보세요.',
            )
          : ListView(
              children: [
                for (final a in likes.items)
                  _SwipeToDelete(key: ValueKey(a.id), album: a),
              ],
            ),
    );
  }
}

/// 왼쪽으로 밀면 삭제 확인 → 삭제 → "실행 취소" 안내
class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({super.key, required this.album});

  final AlbumModel album;

  String get _deleted => '${album.albumName}을(를)\n관심 목록에서 삭제했습니다.';

  void _remove(BuildContext context) {
    final likes = context.deps.likes..toggle(album);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_deleted),
        action: SnackBarAction(
          textColor: AppColor.yellow,
          label: '실행 취소',
          onPressed: () => likes.add(album),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey(album.id),
    direction: DismissDirection.endToStart,
    background: Container(
      color: AppColor.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.all(Gap.xl),
      child: AppIcon.delete.icon(color: AppColor.white, size: Gap.xl),
    ),
    confirmDismiss: (_) => AppConfirmDialog.show(
      context,
      title: '관심 상품 삭제',
      content: _deleted,
      confirm: '삭제',
    ),
    onDismissed: (_) => _remove(context),
    child: _LikeRow(album),
  );
}

class _LikeRow extends StatelessWidget {
  const _LikeRow(this.album);

  final AlbumModel album;

  @override
  Widget build(BuildContext context) => Material(
    clipBehavior: Clip.hardEdge,
    color: AppColor.background,
    child: InkWell(
      onTap: () => context.go(Routes.album, album.id),
      child: Padding(
        padding: const EdgeInsets.all(Gap.l),
        child: Row(
          spacing: Gap.m,
          children: [
            AlbumThumb(album.albumImage, size: 72),
            Expanded(child: _Names(album)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: Gap.xs,
              children: [
                AppText.bold(15, AppColor.yellow).text(Fmt.won(album.price)),
                AppText.regular(
                  12,
                  AppColor.whiteL3,
                ).text(album.tradeMethod.label),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Names extends StatelessWidget {
  const _Names(this.album);

  final AlbumModel album;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Gap.xs,
    children: [
      AppText.bold(15).text(album.albumName, overflow: TextOverflow.ellipsis),
      AppText.regular(
        13,
        AppColor.whiteL1,
      ).text(album.artist, overflow: TextOverflow.ellipsis),
      Row(
        spacing: Gap.s,
        children: [
          ConditionBadge(album.condition),
          AppText.regular(12, AppColor.whiteL3).text(album.genre.label),
        ],
      ),
    ],
  );
}
