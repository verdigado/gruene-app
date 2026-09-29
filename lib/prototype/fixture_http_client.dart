import 'dart:async';
import 'dart:convert';

import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/prototype/fixtures/empty_shapes.g.dart';
import 'package:gruene_app/prototype/fixtures/fixtures.dart';
import 'package:http/http.dart' as http;

/// Serves canned responses instead of calling the Gruene API.
///
/// This sits at the transport layer rather than replacing the generated
/// services, so chopper's converters still parse fixtures into the real
/// swagger models. A fixture is therefore just the JSON the API would return —
/// nothing has to be kept in sync with Dart model classes by hand.
class FixtureHttpClient extends http.BaseClient {
  FixtureHttpClient({this.latency = const Duration(milliseconds: 180)});

  /// Fake network delay, so loading states are actually visible when demoing.
  final Duration latency;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await Future<void>.delayed(latency);

    final method = request.method.toUpperCase();
    final path = request.url.path;
    final body = request is http.Request ? request.body : '';

    final match = resolveFixture(method: method, path: path, requestBody: body, query: request.url.queryParameters);

    if (match == null) {
      // Loud on purpose: an unfixtured endpoint is the signal to add one. The
      // body still has to match the shape the generated converter expects —
      // answering every endpoint with `[]` turns a missing fixture into an
      // unrelated cast error, and inside a dialog into an endless spinner.
      final empty = _emptyBodyFor(method, path);
      logger.w('PROTOTYPE: no fixture for $method $path — returning empty $empty');
      return _json(empty, 200, request);
    }

    logger.d('PROTOTYPE: $method $path -> ${match.status}');
    return _json(jsonEncode(match.body), match.status, request);
  }

  /// The empty response for an unfixtured endpoint, in the shape the spec
  /// declares for it (see `tools/prototype/gen_empty_shapes.py`).
  String _emptyBodyFor(String method, String path) {
    if (method != 'GET') return '{}';

    final shape = emptyShapes[path] ?? _matchTemplatedPath(path);
    return switch (shape) {
      EmptyShape.array => '[]',
      // The generator promotes optional response fields to required and
      // non-nullable, so an empty wrapper has to carry them or parsing throws a
      // cast error far from the cause. The API uses two pagination
      // conventions — a `meta` object and flat total/offset/limit — and the
      // challenge leaderboard adds lastUpdate. Sending the superset is
      // harmless: models ignore keys they do not declare.
      EmptyShape.wrapper =>
        '{"data":[],"meta":{},"total":0,"offset":0,"limit":0,"lastUpdate":"2026-01-01T00:00:00.000Z"}',
      EmptyShape.object => '{}',
      null => '[]',
    };
  }

  /// Falls back to matching paths that carry parameters, e.g.
  /// `/v1/news/{newsId}` against `/v1/news/abc123`.
  EmptyShape? _matchTemplatedPath(String path) {
    final segments = path.split('/');
    for (final entry in emptyShapes.entries) {
      final template = entry.key.split('/');
      if (template.length != segments.length) continue;

      var matches = true;
      for (var i = 0; i < template.length; i++) {
        final part = template[i];
        if (part.startsWith('{') && part.endsWith('}')) continue;
        if (part != segments[i]) {
          matches = false;
          break;
        }
      }
      if (matches) return entry.value;
    }
    return null;
  }

  http.StreamedResponse _json(String payload, int status, http.BaseRequest request) {
    final bytes = utf8.encode(payload);
    return http.StreamedResponse(
      Stream.value(bytes),
      status,
      request: request,
      contentLength: bytes.length,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
