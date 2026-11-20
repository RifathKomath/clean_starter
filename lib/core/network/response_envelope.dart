import 'app_exception.dart';

/// Unwraps a `{status, status_code, message, data}` response body.
///
/// Some responses arrive wrapped in a one-item array, so both shapes are
/// accepted. Anything else returns an empty map, which callers treat as a failure.
Map<String, dynamic> unwrapResponseEnvelope(dynamic body) {
  if (body is List && body.isNotEmpty && body.first is Map<String, dynamic>) {
    return body.first as Map<String, dynamic>;
  }
  if (body is Map<String, dynamic>) return body;
  return const {};
}

/// Reads a list response. Accepts the `{status, data}` envelope (optionally
/// one-item wrapped) and also a plain JSON array of objects that has no
/// envelope. Throws [ApiException] when the envelope reports failure.
List<Map<String, dynamic>> extractResponseList(
  dynamic body, {
  required String failureMessage,
  int? statusCode,
}) {
  final isPlainArray =
      body is List &&
      (body.isEmpty ||
          (body.first is Map && !(body.first as Map).containsKey('status')));
  if (isPlainArray) {
    return body.whereType<Map<String, dynamic>>().toList();
  }

  final envelope = unwrapResponseEnvelope(body);
  if (envelope['status'] != true) {
    final message = (envelope['message'] ?? '').toString();
    throw ApiException(
      message: message.isNotEmpty ? message : failureMessage,
      statusCode: statusCode,
    );
  }

  final data = envelope['data'];
  if (data is! List) return [];
  return data.whereType<Map<String, dynamic>>().toList();
}
