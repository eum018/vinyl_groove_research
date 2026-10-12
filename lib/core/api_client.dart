import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// 성공 아니면 실패. sealed라서 switch에서 Err를 빠뜨리면 컴파일이 안 된다.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value, {this.message, this.meta = const {}});
  final T value;
  final String? message; // 서버가 준 안내 문구 ("등록되었습니다" 등)
  final Map<String, dynamic> meta; // 페이지 정보 등
}

final class Err<T> extends Result<T> {
  const Err(this.message, {this.fields = const {}});
  final String message;
  final Map<String, String> fields; // {'price': '가격은 1,000원 이상 입력해주세요.'}
}

/// 서버 통신은 전부 여기를 지난다. 서버 주소·타임아웃·에러 처리는 이 파일에 한 번씩만 있다.
class ApiClient {
  ApiClient({required this.token, http.Client? client})
    : _client = client ?? http.Client();

  static const host = '192.168.100.200';
  static const authority = '$host:5003';
  static const _timeout = Duration(seconds: 10);

  final String? Function() token;
  final http.Client _client;

  Future<Result<dynamic>> get(String path, [Map<String, String?>? query]) =>
      _send('GET', path, query: query);

  Future<Result<dynamic>> post(String path, Object body) =>
      _send('POST', path, body: body);

  Future<Result<dynamic>> put(String path, [Map<String, String?>? query]) =>
      _send('PUT', path, query: query);

  Future<Result<dynamic>> delete(String path) => _send('DELETE', path);

  /// 서버가 포트 없이 준 이미지 주소를 실제 주소로 바꾼다
  static String imageUrl(String? url) =>
      url?.replaceFirst(host, authority) ?? '';

  Future<Result<dynamic>> _send(
    String method,
    String path, {
    Map<String, String?>? query,
    Object? body,
  }) async {
    final params = {...?query}..removeWhere((_, v) => v == null);
    final uri = Uri.http(authority, path, params.isEmpty ? null : params);
    final req = http.Request(method, uri)..headers.addAll(_headers());
    if (body != null) req.body = jsonEncode(body);

    try {
      final res = await _call(req).timeout(_timeout);
      if (res.statusCode == 429) {
        return const Err('요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.');
      }
      return _parse(jsonDecode(utf8.decode(res.bodyBytes)));
    } on TimeoutException {
      return const Err('서버 응답이 없습니다. 잠시 후 다시 시도해 주세요.');
    } on SocketException {
      return const Err('서버 통신 에러');
    } on http.ClientException {
      return const Err('서버 통신 에러');
    } on FormatException {
      return const Err('서버 응답을 읽을 수 없습니다.');
    }
  }

  Future<http.Response> _call(http.Request req) async =>
      http.Response.fromStream(await _client.send(req));

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    if (token() case final t?) 'Authorization': 'Bearer $t',
  };

  static Result<dynamic> _parse(Object? json) {
    if (json is! Map) return const Err('서버 응답을 읽을 수 없습니다.');
    final message = json['message'] is String
        ? json['message'] as String
        : null;
    if (json['success'] == true) {
      return Ok(json['data'], message: message, meta: {...json});
    }
    // 에러 배열이 비어 있거나 없어도 죽지 않는다
    final errors = (json['errors'] as List?)?.whereType<Map>() ?? const [];
    return Err(
      errors.map((e) => e['message']).whereType<String>().firstOrNull ??
          message ??
          'error',
      fields: {
        for (final e in errors)
          if (e['field'] is String && e['message'] is String)
            e['field'] as String: e['message'] as String,
      },
    );
  }
}
