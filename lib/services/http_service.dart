import 'dart:async';
import 'package:http/http.dart' as http;

/// Service pour gérer les requêtes HTTP avec retry et gestion d'erreurs
class HttpService {
  /// Fait une requête POST avec retry automatique en cas d'échec
  static Future<http.Response> postWithRetry({
    required Uri url,
    required Map<String, String> headers,
    required String body,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    Duration currentDelay = retryDelay;

    while (attempts < maxRetries) {
      try {
        attempts++;
        print('🔄 Tentative HTTP $attempts/$maxRetries vers ${url.host}');

        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));

        // Si succès (2xx) ou erreur client (4xx), on retourne directement
        if (response.statusCode < 500) {
          return response;
        }

        // Erreur serveur (5xx), on retry
        print('⚠️ Erreur serveur ${response.statusCode}, retry dans ${currentDelay.inSeconds}s...');

        if (attempts < maxRetries) {
          await Future.delayed(currentDelay);
          currentDelay *= 2; // Exponential backoff
        }
      } on TimeoutException catch (e) {
        print('⏱️ Timeout lors de la tentative $attempts: $e');
        if (attempts >= maxRetries) rethrow;

        await Future.delayed(currentDelay);
        currentDelay *= 2;
      } catch (e) {
        print('❌ Erreur lors de la tentative $attempts: $e');
        if (attempts >= maxRetries) rethrow;

        await Future.delayed(currentDelay);
        currentDelay *= 2;
      }
    }

    throw Exception('Échec après $maxRetries tentatives');
  }

  /// Fait une requête GET avec retry automatique
  static Future<http.Response> getWithRetry({
    required Uri url,
    Map<String, String>? headers,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    Duration currentDelay = retryDelay;

    while (attempts < maxRetries) {
      try {
        attempts++;
        print('🔄 GET tentative $attempts/$maxRetries vers ${url.host}');

        final response = await http
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 30));

        if (response.statusCode < 500) {
          return response;
        }

        print('⚠️ Erreur serveur ${response.statusCode}, retry dans ${currentDelay.inSeconds}s...');

        if (attempts < maxRetries) {
          await Future.delayed(currentDelay);
          currentDelay *= 2;
        }
      } on TimeoutException catch (e) {
        print('⏱️ Timeout lors de la tentative $attempts: $e');
        if (attempts >= maxRetries) rethrow;

        await Future.delayed(currentDelay);
        currentDelay *= 2;
      } catch (e) {
        print('❌ Erreur lors de la tentative $attempts: $e');
        if (attempts >= maxRetries) rethrow;

        await Future.delayed(currentDelay);
        currentDelay *= 2;
      }
    }

    throw Exception('Échec après $maxRetries tentatives');
  }
}
