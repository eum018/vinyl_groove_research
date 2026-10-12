import '../core/api_client.dart';
import '../domain/models.dart';

abstract class NotificationRepository {
  Future<Result<AlertBox>> fetch();

  /// id 하나 읽음, 또는 all: true로 전부 읽음
  Future<Result<void>> read({int? id, bool all = false});

  Future<Result<void>> deleteAll();
}

class HttpNotificationRepository implements NotificationRepository {
  HttpNotificationRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<AlertBox>> fetch() async =>
      switch (await _api.get('/notifications')) {
        Ok(:final value) => Ok(AlertBox.from(value)),
        Err(:final message) => Err(message),
      };

  @override
  Future<Result<void>> read({int? id, bool all = false}) => _api.put(
    '/notifications/read',
    {'id': id?.toString(), 'all': all ? 'true' : null},
  );

  @override
  Future<Result<void>> deleteAll() => _api.delete('/notifications');
}
