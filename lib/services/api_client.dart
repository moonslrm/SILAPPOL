import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  ApiClient({http.Client? client, FlutterSecureStorage? secureStorage})
    : _client = client ?? http.Client(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  Future<String?> readToken() {
    return _secureStorage.read(key: ApiConfig.tokenStorageKey);
  }

  Future<void> saveToken(String token) {
    return _secureStorage.write(key: ApiConfig.tokenStorageKey, value: token);
  }

  Future<void> clearToken() {
    return _secureStorage.delete(key: ApiConfig.tokenStorageKey);
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '${ApiConfig.baseUrl}$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _headers({bool authorized = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authorized) {
      final token = await readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> getJson(
    String path, {
    Map<String, String>? queryParameters,
    bool authorized = true,
  }) async {
    return _client.get(
      _buildUri(path, queryParameters),
      headers: await _headers(authorized: authorized),
    );
  }

  Future<http.Response> postJson(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) async {
    return _client.post(
      _buildUri(path),
      headers: await _headers(authorized: authorized),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
  }

  Future<http.Response> putJson(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) async {
    return _client.put(
      _buildUri(path),
      headers: await _headers(authorized: authorized),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
  }

  Future<http.Response> deleteJson(
    String path, {
    bool authorized = true,
  }) async {
    return _client.delete(
      _buildUri(path),
      headers: await _headers(authorized: authorized),
    );
  }
}
