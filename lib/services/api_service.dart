import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/booking.dart';
import '../models/jadwal_slot.dart';
import '../models/lapangan.dart';
import '../models/user.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiService {
  ApiService({http.Client? client, FlutterSecureStorage? secureStorage})
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

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? nim,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/register',
      authorized: false,
      body: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'nim': nim,
      },
    );

    final payload = _decodeMap(response.body);
    _storeTokenFromPayload(payload);
    return User.fromJson(
      _extractMap(payload, ['data', 'user'], fallback: payload),
    );
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/login',
      authorized: false,
      body: <String, dynamic>{'email': email, 'password': password},
    );

    final payload = _decodeMap(response.body);
    _storeTokenFromPayload(payload);
    return User.fromJson(
      _extractMap(payload, ['data', 'user'], fallback: payload),
    );
  }

  Future<User> getUserProfile() async {
    final response = await _sendJson(method: 'GET', path: '/user');
    final payload = _decodeMap(response.body);
    return User.fromJson(
      _extractMap(payload, ['data', 'user'], fallback: payload),
    );
  }

  Future<List<Lapangan>> getAdminLapangan() async {
    final response = await _sendJson(method: 'GET', path: '/admin/lapangan');
    final payload = _decodeDynamic(response.body);
    final items = _extractCollection(payload, ['data', 'lapangan']);
    return items
        .whereType<Map<String, dynamic>>()
        .map(Lapangan.fromJson)
        .toList(growable: false);
  }

  Future<Lapangan> createAdminLapangan({
    required String namaLapangan,
    required String jenisLapangan,
    String? deskripsi,
    String? lokasi,
    required double hargaPerJam,
    int? kapasitas,
    required bool statusAktif,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/admin/lapangan',
      body: <String, dynamic>{
        'nama_lapangan': namaLapangan,
        'jenis_lapangan': jenisLapangan,
        'deskripsi': deskripsi,
        'lokasi': lokasi,
        'harga_per_jam': hargaPerJam,
        'kapasitas': kapasitas,
        'status_aktif': statusAktif,
      },
    );

    final payload = _decodeMap(response.body);
    return Lapangan.fromJson(
      _extractMap(payload, ['data', 'lapangan'], fallback: payload),
    );
  }

  Future<Lapangan> updateAdminLapangan({
    required int id,
    required String namaLapangan,
    required String jenisLapangan,
    String? deskripsi,
    String? lokasi,
    required double hargaPerJam,
    int? kapasitas,
    required bool statusAktif,
  }) async {
    final response = await _sendJson(
      method: 'PUT',
      path: '/admin/lapangan/$id',
      body: <String, dynamic>{
        'nama_lapangan': namaLapangan,
        'jenis_lapangan': jenisLapangan,
        'deskripsi': deskripsi,
        'lokasi': lokasi,
        'harga_per_jam': hargaPerJam,
        'kapasitas': kapasitas,
        'status_aktif': statusAktif,
      },
    );

    final payload = _decodeMap(response.body);
    return Lapangan.fromJson(
      _extractMap(payload, ['data', 'lapangan'], fallback: payload),
    );
  }

  Future<void> deleteAdminLapangan(int id) async {
    await _sendJson(method: 'DELETE', path: '/admin/lapangan/$id');
  }

  Future<Lapangan> toggleAdminLapanganStatus(int id) async {
    final response = await _sendJson(
      method: 'PATCH',
      path: '/admin/lapangan/$id/toggle-status',
    );

    final payload = _decodeMap(response.body);
    return Lapangan.fromJson(
      _extractMap(payload, ['data', 'lapangan'], fallback: payload),
    );
  }

  Future<void> logout() async {
    try {
      await _sendJson(method: 'POST', path: '/logout');
    } finally {
      await clearToken();
    }
  }

  Future<List<Lapangan>> getLapangan({String? jenis}) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/lapangan',
      authorized: false,
      queryParameters: jenis == null || jenis.isEmpty
          ? null
          : <String, String>{'jenis': jenis},
    );

    final payload = _decodeDynamic(response.body);
    final items = _extractCollection(payload, ['data', 'lapangan']);
    return items
        .whereType<Map<String, dynamic>>()
        .map(Lapangan.fromJson)
        .toList(growable: false);
  }

  Future<Lapangan> getDetailLapangan(int id) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/lapangan/$id',
      authorized: false,
    );

    final payload = _decodeMap(response.body);
    return Lapangan.fromJson(
      _extractMap(payload, ['data', 'lapangan'], fallback: payload),
    );
  }

  Future<List<JadwalSlot>> getSlotTersedia(int id, DateTime tanggal) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/lapangan/$id/slot',
      authorized: false,
      queryParameters: <String, String>{'tanggal': _formatDate(tanggal)},
    );

    final payload = _decodeDynamic(response.body);
    final items = _extractCollection(payload, ['data', 'slots']);
    return items
        .whereType<Map<String, dynamic>>()
        .map(JadwalSlot.fromJson)
        .toList(growable: false);
  }

  Future<Booking> createBooking({
    required int lapanganId,
    required DateTime tanggalSewa,
    required String jamMulai,
    required String jamSelesai,
    int? jumlahPeserta,
    String? catatan,
  }) async {
    final response = await _sendJson(
      method: 'POST',
      path: '/booking',
      body: <String, dynamic>{
        'lapangan_id': lapanganId,
        'tanggal_sewa': _formatDate(tanggalSewa),
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'jumlah_peserta': jumlahPeserta,
        'catatan': catatan,
      },
    );

    final payload = _decodeMap(response.body);
    return Booking.fromJson(
      _extractMap(payload, ['data', 'booking'], fallback: payload),
    );
  }

  Future<List<Booking>> getBookingSaya({String? status}) async {
    final response = await _sendJson(
      method: 'GET',
      path: '/booking/saya',
      queryParameters: status == null || status.isEmpty
          ? null
          : <String, String>{'status': status},
    );

    final payload = _decodeDynamic(response.body);
    final items = _extractCollection(payload, ['data', 'bookings']);
    return items
        .whereType<Map<String, dynamic>>()
        .map(Booking.fromJson)
        .toList(growable: false);
  }

  Future<Booking> cancelBooking(int id) async {
    final response = await _sendJson(method: 'DELETE', path: '/booking/$id');

    final payload = _decodeMap(response.body);
    return Booking.fromJson(
      _extractMap(payload, ['data', 'booking'], fallback: payload),
    );
  }

  Future<http.Response> _sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authorized = true,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders(authorized: authorized);
    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers);
          break;
        default:
          throw ApiException('Metode HTTP tidak didukung.');
      }
    } catch (_) {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }

    if (!_isSuccessStatus(response.statusCode)) {
      throw ApiException(
        _extractErrorMessage(
          response.body,
          fallback: _defaultErrorMessage(response.statusCode),
        ),
        statusCode: response.statusCode,
      );
    }

    return response;
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '${ApiConfig.baseUrl}$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _buildHeaders({required bool authorized}) async {
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

  dynamic _decodeDynamic(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(body);
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = _decodeDynamic(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  List<dynamic> _extractCollection(dynamic payload, List<String> path) {
    final value = _extractValue(payload, path);
    if (value is List) {
      return value;
    }

    if (payload is List) {
      return payload;
    }

    return const <dynamic>[];
  }

  Map<String, dynamic> _extractMap(
    Map<String, dynamic> payload,
    List<String> path, {
    required Map<String, dynamic> fallback,
  }) {
    final value = _extractValue(payload, path);
    if (value is Map<String, dynamic>) {
      return value;
    }

    return fallback;
  }

  dynamic _extractValue(dynamic payload, List<String> path) {
    dynamic current = payload;
    for (final key in path) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current;
  }

  void _storeTokenFromPayload(Map<String, dynamic> payload) {
    final token = _extractToken(payload);
    if (token != null && token.isNotEmpty) {
      saveToken(token);
    }
  }

  String? _extractToken(Map<String, dynamic> payload) {
    final directToken = payload['token']?.toString();
    if (directToken != null && directToken.isNotEmpty) {
      return directToken;
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final nestedToken = data['token']?.toString();
      if (nestedToken != null && nestedToken.isNotEmpty) {
        return nestedToken;
      }
    }

    return null;
  }

  String _extractErrorMessage(String body, {required String fallback}) {
    if (body.trim().isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) {
          final validationMessage = _extractValidationMessage(decoded);
          if (validationMessage != null && validationMessage.isNotEmpty) {
            return validationMessage;
          }

          return message;
        }

        final validationMessage = _extractValidationMessage(decoded);
        if (validationMessage != null && validationMessage.isNotEmpty) {
          return validationMessage;
        }
      }
    } catch (_) {
      return body;
    }

    return fallback;
  }

  String? _extractValidationMessage(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final messages = <String>[];
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            messages.add(value.first.toString());
          } else if (value != null) {
            messages.add(value.toString());
          }
        }

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }

    return null;
  }

  bool _isSuccessStatus(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  String _defaultErrorMessage(int statusCode) {
    if (statusCode == 401) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }

    if (statusCode == 403) {
      return 'Anda tidak memiliki akses untuk tindakan ini.';
    }

    if (statusCode == 404) {
      return 'Data yang diminta tidak ditemukan.';
    }

    if (statusCode >= 500) {
      return 'Terjadi kesalahan pada server. Coba lagi nanti.';
    }

    return 'Permintaan gagal diproses.';
  }

  String _formatDate(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final year = localDate.year.toString().padLeft(4, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
