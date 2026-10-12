import 'enums.dart';

/// 서버 JSON은 믿을 수 없는 외부 입력이다. 값이 없거나 모양이 달라도 예외를 던지지 않는다.
int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
String _str(Object? v) => v is String ? v : '';
String? _opt(Object? v) => v is String ? v : null;
Map _map(Object? v) => v is Map ? v : const {};
List _list(Object? v) => v is List ? v : const [];

class AlbumModel {
  const AlbumModel({
    required this.id,
    required this.albumName,
    required this.artist,
    required this.genre,
    required this.condition,
    required this.price,
    required this.tradeMethod,
    required this.albumImage,
    required this.likeCount,
    required this.createdAt,
  });

  factory AlbumModel.from(Object? json) {
    final j = _map(json);
    return AlbumModel(
      id: _int(j['id']),
      albumName: _str(j['albumName']),
      artist: _str(j['artist']),
      genre: Genre.fromCode(_opt(j['genre'])) ?? Genre.etc,
      condition: Condition.fromCode(_opt(j['condition'])) ?? Condition.g,
      price: _int(j['price']),
      tradeMethod: Trade.fromCode(_opt(j['tradeMethod'])) ?? Trade.both,
      albumImage: _str(j['albumImage']),
      likeCount: _int(j['likeCount']),
      createdAt: _str(j['createdAt']),
    );
  }

  final int id;
  final String albumName;
  final String artist;
  final Genre genre;
  final Condition condition;
  final int price;
  final Trade tradeMethod;
  final String albumImage;
  final int likeCount;
  final String createdAt;

  Map<String, Object> toJson() => {
    'id': id,
    'albumName': albumName,
    'artist': artist,
    'genre': genre.code,
    'condition': condition.code,
    'price': price,
    'tradeMethod': tradeMethod.code,
    'albumImage': albumImage,
    'likeCount': likeCount,
    'createdAt': createdAt,
  };

  @override
  bool operator ==(Object other) => other is AlbumModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 상품 상세 (GET /products/{id})
class AlbumDetail {
  AlbumDetail.from(Object? json)
    : album = AlbumModel.from(json),
      sellerName = _str(_map(_map(json)['seller'])['name']),
      sellerEmail = _str(_map(_map(json)['seller'])['email']),
      sellerImage = _opt(_map(_map(json)['seller'])['profileImage']),
      conditionDescription = _str(_map(json)['conditionDescription']),
      description = _str(_map(json)['description']);

  final AlbumModel album;
  final String sellerName;
  final String sellerEmail;
  final String? sellerImage;
  final String conditionDescription;
  final String description;
}

/// 상품 등록 입력값 (POST /products)
class ProductDraft {
  const ProductDraft({
    required this.albumName,
    required this.artist,
    required this.genre,
    required this.condition,
    required this.price,
    required this.trade,
    required this.barcode,
    required this.description,
    required this.image,
  });

  final String albumName, artist, barcode, description;
  final Genre? genre;
  final Condition? condition;
  final Trade? trade;
  final int price;
  final String? image;

  Map<String, Object?> toJson() => {
    'albumName': albumName,
    'artist': artist,
    'genre': genre?.code,
    'condition': condition?.code,
    'price': price,
    'tradeMethod': trade?.code,
    'barcode': barcode,
    'description': description,
    'albumImage': image,
  };
}

class User {
  const User({required this.name, required this.email});

  User.from(Object? json)
    : name = _str(_map(json)['name']),
      email = _str(_map(json)['email']);

  final String name;
  final String email;
}

class AlertModel {
  AlertModel.from(Object? json)
    : id = _int(_map(json)['id']),
      productId = _int(_map(json)['productId']),
      title = _str(_map(json)['title']),
      albumName = _str(_map(json)['albumName']),
      albumImage = _str(_map(json)['albumImage']),
      previousPrice = _int(_map(json)['previousPrice']),
      currentPrice = _int(_map(json)['currentPrice']),
      createdAt =
          DateTime.tryParse(_str(_map(json)['createdAt'])) ?? DateTime.now(),
      isRead = _map(json)['isRead'] == true;

  final int id, productId, previousPrice, currentPrice;
  final String title, albumName, albumImage;
  final DateTime createdAt;
  final bool isRead;

  bool get isPriceDown => title == '가격 인하';
}

/// GET /notifications 결과
class AlertBox {
  const AlertBox(this.unreadCount, this.items);

  AlertBox.from(Object? json)
    : unreadCount = _int(_map(json)['unreadCount']),
      items = [
        for (final e in _list(_map(json)['notifications'])) AlertModel.from(e),
      ];

  static const empty = AlertBox(0, []);

  final int unreadCount;
  final List<AlertModel> items;
}
