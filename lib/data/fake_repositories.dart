import 'dart:typed_data';

import '../core/api_client.dart';
import '../domain/enums.dart';
import '../domain/models.dart';
import '../domain/search_filter.dart';
import 'auth_repository.dart';
import 'notification_repository.dart';
import 'product_repository.dart';

/// 서버 없이 화면을 띄울 때 쓰는 가짜들 (Deps.fake(), 테스트)
final sampleAlbums = [
  for (final (i, name) in ['Blonde', 'Kind of Blue', 'Thriller'].indexed)
    AlbumModel(
      id: i + 1,
      albumName: name,
      artist: 'Artist ${i + 1}',
      genre: Genre.values[i],
      condition: Condition.values[i + 1],
      price: 10000 * (i + 1),
      tradeMethod: Trade.both,
      albumImage: '',
      likeCount: 0,
      createdAt: '2026-05-20T10:00:00Z',
    ),
];

class FakeProductRepository implements ProductRepository {
  FakeProductRepository([List<AlbumModel>? albums])
    : albums = albums ?? sampleAlbums;

  final List<AlbumModel> albums;
  final likes = <AlbumModel>[];

  Ok<List<AlbumModel>> get _all =>
      Ok(albums, meta: {'total': albums.length, 'hasNext': false});

  @override
  Future<Result<List<AlbumModel>>> bySort(Sort s, {required int limit}) async =>
      _all;
  @override
  Future<Result<List<AlbumModel>>> byArtist(String artist) async => _all;
  @override
  Future<Result<List<AlbumModel>>> search(SearchFilter f, int page) async =>
      _all;
  @override
  Future<Result<List<AlbumModel>>> byBarcode(String barcode) async => _all;
  @override
  Future<Result<List<AlbumModel>>> mine() async => _all;
  @override
  Future<Result<AlbumDetail>> detail(int id) async =>
      Ok(AlbumDetail.from(albums.firstWhere((a) => a.id == id).toJson()));
  @override
  Future<Result<void>> create(ProductDraft draft) async => const Ok(null);
  @override
  Future<Result<void>> remove(int id) async => const Ok(null);
  @override
  Future<Result<String>> uploadImage(Uint8List b, String? m) async =>
      const Ok('');
  @override
  Future<Result<List<AlbumModel>>> restoreLikes() async => Ok([...likes]);
  @override
  Future<void> saveLikes(Iterable<AlbumModel> v) async => likes
    ..clear()
    ..addAll(v);
  @override
  Future<void> clearLikes() async => likes.clear();
}

class FakeAuthRepository implements AuthRepository {
  List<int>? pin;

  @override
  Future<Result<Session>> login(String email, String password) async =>
      Ok((token: 'fake', user: User(name: '테스트', email: email)));
  @override
  Future<Result<void>> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async => const Ok(null);
  @override
  List<int>? loadPin() => pin;
  @override
  Future<void> savePin(List<int> p) async => pin = p;
  @override
  Future<void> clearPin() async => pin = null;
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<Result<AlertBox>> fetch() async => const Ok(AlertBox.empty);
  @override
  Future<Result<void>> read({int? id, bool all = false}) async =>
      const Ok(null);
  @override
  Future<Result<void>> deleteAll() async => const Ok(null);
}
