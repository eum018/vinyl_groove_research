import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/chip_group.dart';
import '../../core/widgets/filter_button.dart';
import '../../data/stores/search_store.dart';
import '../../domain/enums.dart';
import '../../domain/search_filter.dart';

/// 탐색 필터: 장르·음반 상태·가격·거래 방식. 바꾸면 SearchStore가 알아서 다시 조회한다.
class SearchFilterPanel extends StatefulWidget {
  const SearchFilterPanel({super.key, required this.store});

  final SearchStore store;

  @override
  State<SearchFilterPanel> createState() => _SearchFilterPanelState();
}

class _SearchFilterPanelState extends State<SearchFilterPanel> {
  bool _folded = false;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final f = store.filter;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Column(
        children: [
          _Header(onReset: store.resetFilter),
          if (!_folded) ...[
            _Line(
              '장르',
              ChipGroup(
                key: const Key('filter_genre'),
                items: Genre.values,
                labelOf: (g) => g.label,
                isSelected: f.genres.contains,
                onTap: store.addGenre,
                onAll: store.allGenres,
                allSelected: f.genres.isEmpty,
              ),
            ),
            _Line(
              '음반 상태',
              ChipGroup(
                key: const Key('filter_condition'),
                items: Condition.forFilter,
                labelOf: (c) => c.chipLabel,
                isSelected: f.conditions.contains,
                onTap: store.addCondition,
                onAll: store.allConditions,
                allSelected: f.conditions.isEmpty,
              ),
            ),
            _Line('가격 범위', _PriceRange(store)),
            _Line(
              '거래 방식',
              ChipGroup(
                key: const Key('filter_trade'),
                items: Trade.values,
                labelOf: (t) => t.label,
                isSelected: (t) => f.trade == t,
                onTap: store.tradeBy,
                onAll: () => store.tradeBy(null),
                allSelected: f.trade == null,
              ),
            ),
          ],
          _FoldButton(
            folded: _folded,
            onTap: () => setState(() => _folded = !_folded),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Row(
    spacing: Gap.m,
    children: [
      const Icon(Icons.tune, color: AppColor.whiteL1, size: 18),
      AppText.medium(15).text('필터'),
      const Spacer(),
      TextButton(
        key: const Key('filter_reset'),
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
        ),
        onPressed: onReset,
        child: AppText.medium(14, AppColor.yellow).text('필터 초기화'),
      ),
    ],
  );
}

/// 왼쪽 이름 + 오른쪽 내용 한 줄
class _Line extends StatelessWidget {
  const _Line(this.label, this.child);

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 64,
        child: AppText.regular(12, AppColor.whiteL1).text(label),
      ),
      Expanded(child: child),
    ],
  );
}

class _PriceRange extends StatelessWidget {
  const _PriceRange(this.store);

  final SearchStore store;

  @override
  Widget build(BuildContext context) {
    final f = store.filter;
    final top = f.maxPrice == SearchFilter.priceCeil;
    return Row(
      spacing: 6,
      children: [
        FilterButton(
          label: Fmt.won(f.minPrice),
          selected: false,
          onPressed: () {},
        ),
        Expanded(
          child: RangeSlider(
            key: const Key('filter_price'),
            min: SearchFilter.priceFloor,
            max: SearchFilter.priceCeil,
            activeColor: AppColor.yellow,
            padding: EdgeInsets.zero,
            values: RangeValues(f.minPrice, f.maxPrice),
            onChanged: (v) => store.dragPrice(v.start, v.end),
            onChangeEnd: (_) => store.commitPrice(),
          ),
        ),
        FilterButton(
          label: top ? '₩1,000,000+' : Fmt.won(f.maxPrice),
          selected: false,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _FoldButton extends StatelessWidget {
  const _FoldButton({required this.folded, required this.onTap});

  final bool folded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
    key: const Key('filter_fold'),
    onPressed: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Gap.xs,
      children: [
        AppText.medium(12, AppColor.whiteL1).text(folded ? '펼치기' : '접기'),
        Icon(
          folded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
          color: AppColor.whiteL1,
          size: 14,
        ),
      ],
    ),
  );
}
