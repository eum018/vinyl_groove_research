import 'package:flutter/material.dart';

import '../../core/app_icon.dart';
import '../../core/theme.dart';
import '../../domain/enums.dart';

extension GenreIcon on Genre {
  AppIcon get icon => switch (this) {
    Genre.rock => AppIcon.rock,
    Genre.jazz => AppIcon.jazz,
    Genre.pop => AppIcon.pop,
    Genre.hiphop => AppIcon.hip,
    Genre.electronic => AppIcon.electronic,
    Genre.classical => AppIcon.classical,
    Genre.rnbSoul => AppIcon.rnb,
    Genre.etc => AppIcon.etc,
  };
}

/// "장르별 둘러보기" 4×2 칸
class GenreGrid extends StatelessWidget {
  const GenreGrid({super.key, required this.onTap});

  final ValueChanged<Genre> onTap;

  @override
  Widget build(BuildContext context) => GridView(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      mainAxisExtent: 68,
    ),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (final g in Genre.values)
        Card(
          key: Key('genre_${g.code}'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColor.whiteL4),
          ),
          color: AppColor.blackL1,
          child: InkWell(onTap: () => onTap(g), child: _GenreCell(g)),
        ),
    ],
  );
}

class _GenreCell extends StatelessWidget {
  const _GenreCell(this.genre);

  final Genre genre;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Gap.xs),
    child: Column(
      spacing: Gap.xs,
      children: [
        genre.icon.icon(color: AppColor.yellow, size: 28),
        AppText.regular(12).text(genre.gridLabel),
      ],
    ),
  );
}
