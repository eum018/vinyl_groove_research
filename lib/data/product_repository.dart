import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../domain/enums.dart';
import '../domain/models.dart';
import '../domain/search_filter.dart';

abstract class ProductRepository {
  Future<Result<List<AlbumModel>>> bySort(Sort sort, {required int limit});
  Future<Result<List<AlbumModel>>> byArtist(String artist);
  Future<Result<List<AlbumModel>>> search(SearchFilter filter, int page);
  Future<Result<List<AlbumModel>>> byBarcode(String barcode);
  Future<Result<List<AlbumModel>>> mine();
  Future<Result<AlbumDetail>> detail(int id);
  Future<Result<void>> create(ProductDraft draft);
  Future<Result<void>> remove(int id);

  /// 성공하면 서버에 올라간 이미지 주소
  Future<Result<String>> uploadImage(Uint8List bytes, String? mimeType);

  Future<Result<List<AlbumModel>>> restoreLikes();
  Future<void> saveLikes(Iterable<AlbumModel> likes);
  Future<void> clearLikes();
}

class HttpProductRepository implements ProductRepository {
  HttpProductRepository(this._api, this._prefs);

  static const _likesKey = 'keyL';

  final ApiClient _api;
  final SharedPreferences _prefs;

  @override
  Future<Result<List<AlbumModel>>> bySort(Sort sort, {required int limit}) =>
      _list({'sort': sort.code, 'limit': '$limit'});

  @override
  Future<Result<List<AlbumModel>>> byArtist(String artist) =>
      _list({'limit': '3', 'keyword': artist});

  @override
  Future<Result<List<AlbumModel>>> search(SearchFilter filter, int page) =>
      _list(filter.toQuery(page));

  @override
  Future<Result<List<AlbumModel>>> byBarcode(String barcode) =>
      _list({'barcode': barcode});

  @override
  Future<Result<List<AlbumModel>>> mine() async =>
      _albums(await _api.get('/products/me'));

  @override
  Future<Result<AlbumDetail>> detail(int id) async =>
      switch (await _api.get('/products/$id')) {
        Ok(:final value) => Ok(AlbumDetail.from(value)),
        Err(:final message) => Err(message),
      };

  @override
  Future<Result<void>> create(ProductDraft draft) =>
      _api.post('/products', draft.toJson());

  @override
  Future<Result<void>> remove(int id) => _api.delete('/products/$id');

  @override
  Future<Result<String>> uploadImage(Uint8List bytes, String? mimeType) async {
    final res = await _api.post('/upload/image', {
      'image': 'data:${mimeType ?? 'image/png'};base64,${base64Encode(bytes)}',
      'type': 'ALBUM',
    });
    return switch (res) {
      Ok(value: final Map value, :final message) => Ok(
        '${value['imageUrl']}',
        message: message,
      ),
      Ok() => const Err('서버 응답을 읽을 수 없습니다.'),
      Err(:final message) => Err(message),
    };
  }

  @override
  Future<Result<List<AlbumModel>>> restoreLikes() async {
    try {
      final saved = _prefs.getStringList(_likesKey) ?? const [];
      return Ok([for (final s in saved) AlbumModel.from(jsonDecode(s))]);
    } on FormatException {
      await _prefs.remove(_likesKey); // 깨진 데이터를 버리고 빈 목록으로 계속 간다
      return const Err('관심상품 복원 실패');
    }
  }

  @override
  Future<void> saveLikes(Iterable<AlbumModel> likes) => _prefs.setStringList(
    _likesKey,
    [for (final a in likes) jsonEncode(a.toJson())],
  );

  @override
  Future<void> clearLikes() => _prefs.remove(_likesKey);

  Future<Result<List<AlbumModel>>> _list(Map<String, String> query) async =>
      _albums(await _api.get('/products', query));

  static Result<List<AlbumModel>> _albums(Result<dynamic> res) => switch (res) {
    Ok(:final value, :final meta) => Ok([
      for (final e in value is List ? value : const []) AlbumModel.from(e),
    ], meta: _page(meta['pagination'])),
    Err(:final message) => Err(message),
  };

  static Map<String, dynamic> _page(Object? p) => p is Map
      ? {'total': p['totalCount'], 'hasNext': p['hasNext'] == true}
      : const {};
}
