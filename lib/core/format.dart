import 'package:intl/intl.dart';

abstract final class Fmt {
  static final _won = NumberFormat('₩#,###');
  static final _wonSpaced = NumberFormat('₩ #,###');

  /// ₩95,000
  static String won(num v) => _won.format(v);

  /// ₩ 95,000 (상품 카드·알림)
  static String wonSpaced(num v) => _wonSpaced.format(v);

  static String ago(DateTime at, [DateTime? now]) {
    final d = (now ?? DateTime.now()).difference(at);
    if (d.inDays >= 1) return '${d.inDays}일 전';
    if (d.inHours >= 1) return '${d.inHours}시간 전';
    if (d.inMinutes >= 1) return '${d.inMinutes}분 전';
    return '방금 전';
  }
}
