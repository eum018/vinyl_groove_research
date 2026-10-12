import 'package:flutter/foundation.dart';

import '../../core/list_controller.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/search_filter.dart';
import '../product_repository.dart';

/// 탐색 필터. 탭을 옮겨도 남는다. 필터를 바꾸는 메서드는 전부 _apply를 거쳐 조회까지 한다.
class SearchStore extends ChangeNotifier {
  SearchStore(ProductRepository repo) : this._(repo, SearchFilter());

  SearchStore._(ProductRepository repo, this.filter)
    : list = ListController((page) => repo.search(filter, page));

  final SearchFilter filter;
  final ListController<AlbumModel> list;

  void keyword(String v) => _apply(() => filter.keyword = v, debounce: true);
  void clearKeyword() => _apply(() => filter.keyword = '');
  void sortBy(Sort v) => _apply(() => filter.sort = v);

  void allGenres() => _apply(filter.genres.clear);
  void addGenre(Genre g) => _apply(() => filter.genres.add(g));
  void onlyGenre(Genre g) => _apply(
    () => filter.genres
      ..clear()
      ..add(g),
  );

  void allConditions() => _apply(filter.conditions.clear);
  void addCondition(Condition c) => _apply(() => filter.conditions.add(c));

  void tradeBy(Trade? t) => _apply(() => filter.trade = t);

  /// 슬라이더를 끄는 동안은 숫자만 바꾸고, 손을 떼면(commit) 조회한다
  void dragPrice(double min, double max) {
    filter
      ..minPrice = min
      ..maxPrice = max;
    notifyListeners();
  }

  void commitPrice() => _apply(() {});

  void resetFilter() => _apply(filter.reset);

  void clear() {
    filter.clear();
    list.reset();
    notifyListeners();
  }

  void _apply(VoidCallback change, {bool debounce = false}) {
    change();
    notifyListeners();
    list.refresh(debounce: debounce);
  }
}
