/// 앱에서 쓰는 "정해진 값"(음반 상태·장르·정렬·거래 방식)은 전부 이 파일에 있다.
library;

enum Condition {
  ss('SS', '미개봉 새상품', filterable: false),
  m('M', 'Mint - 완벽한 상태', chip: 'Mint'),
  nm('NM', 'Near Mint - 거의 새것'),
  ex('EX', 'Excellent - 약간의 사용감', filterable: false),
  vgPlus('VG+', 'Very Good+ - 양호'),
  vg('VG', 'Very Good - 사용감 있음'),
  g('G', 'Good - 재생 가능');

  const Condition(
    this.code,
    this.description, {
    String? chip,
    this.filterable = true,
  }) : _chip = chip;

  final String code;
  final String description;
  final String? _chip;

  /// 탐색 필터에 나오는지. SS·EX는 탐색 필터에 나오지 않는다.
  final bool filterable;

  String get chipLabel => _chip ?? code;

  static List<Condition> get forFilter =>
      values.where((e) => e.filterable).toList();

  static Condition? fromCode(String? c) =>
      values.where((e) => e.code == c).firstOrNull;
}

enum Genre {
  rock('ROCK', 'Rock'),
  jazz('JAZZ', 'Jazz'),
  pop('POP', 'Pop'),
  hiphop('HIPHOP', 'Hip-Hop'),
  electronic('ELECTRONIC', 'Electronic'),
  classical('CLASSICAL', 'Classical'),
  rnbSoul('RNB_SOUL', 'R&B/Soul'),
  etc('ETC', 'Etc', gridLabel: '기타');

  const Genre(this.code, this.label, {String? gridLabel})
    : _gridLabel = gridLabel;

  final String code;
  final String label;
  final String? _gridLabel;

  /// 홈 "장르별 둘러보기" 칸에 쓰는 이름
  String get gridLabel => _gridLabel ?? label;

  static Genre? fromCode(String? c) =>
      values.where((e) => e.code == c).firstOrNull;
}

enum Sort {
  popular('popular', '인기 매물'),
  recent('recent', '최신 등록'),
  priceAsc('price_asc', '가격 인하', menuLabel: '최저 가격순');

  const Sort(this.code, this.label, {String? menuLabel})
    : _menuLabel = menuLabel;

  final String code;
  final String label;
  final String? _menuLabel;

  /// 탐색 화면 정렬 메뉴에 쓰는 이름
  String get menuLabel => _menuLabel ?? '$label순';

  /// 탐색 화면 정렬 메뉴 순서
  static const menuOrder = [recent, popular, priceAsc];
}

enum Trade {
  direct('DIRECT', '직거래'),
  delivery('DELIVERY', '택배'),
  both('BOTH', '둘 다');

  const Trade(this.code, this.label);

  final String code;
  final String label;

  static Trade? fromCode(String? c) =>
      values.where((e) => e.code == c).firstOrNull;
}
