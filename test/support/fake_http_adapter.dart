import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef FakeResponseBuilder =
    FutureOr<ResponseBody> Function(RequestOptions request);

/// An [HttpClientAdapter] that never touches the network.
///
/// Requests are recorded in [requests] so tests can assert on URLs, headers
/// and bodies.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this._builder);

  final FakeResponseBuilder _builder;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return Future<ResponseBody>.sync(() => _builder(options));
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(
  Object? data, {
  int statusCode = 200,
  Map<String, List<String>> headers = const {},
}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...headers,
    },
  );
}

ResponseBody htmlResponse(String body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['text/html; charset=utf-8'],
    },
  );
}

ResponseBody textResponse(
  String body, {
  int statusCode = 200,
  String contentType = 'text/plain; charset=utf-8',
}) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [contentType],
    },
  );
}
