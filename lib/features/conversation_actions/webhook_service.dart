import 'dart:convert';
import 'package:http/http.dart' as http;
import '../push/push_models.dart';

/// Service for calling webhooks (menu actions, user replies)
class WebhookService {
  WebhookService._();

  static final WebhookService instance = WebhookService._();

  /// Call a webhook with optional body
  /// method: GET (default) or POST
  Future<WebhookResponse> callWebhook({
    required String url,
    WebhookMethod method = WebhookMethod.get,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse(url);
      http.Response response;

      if (method == WebhookMethod.post) {
        // POST request with JSON body
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 300));
      } else {
        // GET request with query parameters
        final uriWithParams = body != null && body.isNotEmpty
            ? uri.replace(queryParameters: {
                ...uri.queryParameters,
                ...body.map((k, v) => MapEntry(k, v?.toString() ?? '')),
              })
            : uri;
        response = await http.get(uriWithParams).timeout(const Duration(seconds: 300));
      }

      String? message;
      try {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            message = decoded['message']?.toString();
          }
        }
      } catch (_) {
        // Ignore JSON parsing errors
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return WebhookResponse(
          statusCode: response.statusCode,
          message: message,
        );
      } else {
        return WebhookResponse(
          statusCode: response.statusCode,
          message: message ?? 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return WebhookResponse(
        message: e.toString(),
      );
    }
  }

  /// Call a webhook using Webhook object
  Future<WebhookResponse> callWebhookWithConfig({
    required Webhook webhook,
    Map<String, dynamic>? body,
  }) {
    return callWebhook(
      url: webhook.url,
      method: webhook.method,
      body: body,
    );
  }
}

class WebhookResponse {
  final int? statusCode;
  final String? message;

  const WebhookResponse({
    this.statusCode,
    this.message,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
