import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../core/widgets/condition_badge.dart';
import '../../domain/models.dart';
import 'like_button.dart';

/// 상품 카드 (홈 가로 목록 · 탐색 격자 · 상세의 유사 앨범)
class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album, this.size = 13});

  final AlbumModel album;
  final double size;

  @override
  Widget build(BuildContext context) => Material(
    clipBehavior: Clip.antiAlias,
    color: AppColor.blackL3,
    shape: AppStyle.panel,
    child: InkWell(
      onTap: () => context.go(Routes.album, album.id),
      child: SizedBox(
        width: 140,
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_Cover(album), _Info(album, size)],
        ),
      ),
    ),
  );
}

class _Cover extends StatelessWidget {
  const _Cover(this.album);

  final AlbumModel album;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 120,
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            album.albumImage,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: LikeButton(album: album),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(Gap.s),
            child: ConditionBadge(album.condition),
          ),
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.album, this.size);

  final AlbumModel album;
  final double size;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Gap.s),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Gap.xs,
      children: [
        AppText.bold(
          size,
        ).text(album.albumName, overflow: TextOverflow.ellipsis),
        AppText.regular(
          size - 1,
          AppColor.whiteL1,
        ).text(album.artist, overflow: TextOverflow.ellipsis),
        AppText.bold(size, AppColor.yellow).text(Fmt.wonSpaced(album.price)),
      ],
    ),
  );
}
