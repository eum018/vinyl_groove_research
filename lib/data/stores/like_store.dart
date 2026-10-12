import 'package:flutter/foundation.dart';

import '../../domain/models.dart';
import '../product_repository.dart';

/// 관심상품. 저장은 이 안에서만 한다 — 화면은 toggle만 부른다.
class LikeStore extends ChangeNotifier {
  LikeStore(this._repo, List<AlbumModel> initial) : _items = [...initial];

  final ProductRepository _repo;
  final List<AlbumModel> _items;

  Iterable<AlbumModel> get items => List.unmodifiable(_items);
  bool contains(AlbumModel a) => _items.contains(a);

  Future<void> toggle(AlbumModel a) async {
    if (!_items.remove(a)) _items.add(a);
    notifyListeners();
    await _repo.saveLikes(_items);
  }

  /// 실행 취소용 — 이미 있으면 그대로 둔다
  Future<void> add(AlbumModel a) async {
    if (_items.contains(a)) return;
    _items.add(a);
    notifyListeners();
    await _repo.saveLikes(_items);
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _repo.clearLikes();
  }
}
