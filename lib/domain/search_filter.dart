import 'enums.dart';

/// 탐색 화면 필터. 비어 있는 Set이 "전체"다.
class SearchFilter {
  static const pageSize = 12;
  static const priceFloor = 1000.0;
  static const priceCeil = 1000000.0;

  String keyword = '';
  Sort sort = Sort.popular;
  final genres = <Genre>{};
  final conditions = <Condition>{};
  Trade? trade; // null = 전체
  double minPrice = priceFloor;
  double maxPrice = priceCeil;

  /// "필터 초기화" — 검색어와 정렬은 그대로 둔다
  void reset() {
    genres.clear();
    conditions.clear();
    trade = null;
    minPrice = priceFloor;
    maxPrice = priceCeil;
  }

  /// 로그아웃 때 — 전부 처음으로
  void clear() {
    reset();
    keyword = '';
    sort = Sort.popular;
  }

  Map<String, String> toQuery(int page) => {
    'sort': sort.code,
    'conditions': conditions.map((e) => e.code).join(','),
    'genres': genres.map((e) => e.code).join(','),
    'keyword': keyword,
    'maxPrice': '${maxPrice.toInt()}',
    'minPrice': '${minPrice.toInt()}',
    'page': '$page',
    'size': '$pageSize',
    'tradeMethod': trade?.code ?? '',
  };
}
