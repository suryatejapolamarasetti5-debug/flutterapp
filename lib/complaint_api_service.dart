import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Thrown when a complaint fetch fails, or the payload cannot be read.
class ComplaintApiException implements Exception {
  final String message;

  const ComplaintApiException(this.message);

  @override
  String toString() => message;
}

/// A single streetlight complaint as returned by the REST API.
class Complaint {
  final int id;
  final String type;
  final String location;
  final String description;
  final String priority;
  final String status;
  final String createdAt;
  final String? imageUrl;
  final Uint8List? photo;
  final double? latitude;
  final double? longitude;

  const Complaint({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.imageUrl,
    this.photo,
    this.latitude,
    this.longitude,
  });

  /// Human readable reference, e.g. `SL-004`.
  String get reference => 'SL-${id.toString().padLeft(3, '0')}';

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: _readId(json),
      type: _readString(json, ['complaint_type', 'type', 'category']),
      location: _readString(json, ['location', 'address', 'area']),
      description: _readString(json, ['description', 'details', 'notes']),
      priority:
          _readString(json, ['priority', 'severity'], fallback: 'Medium'),
      status: _readString(json, ['status', 'state'], fallback: 'Pending'),
      createdAt: _readString(json, ['created_at', 'createdAt', 'date']),
      imageUrl: _readStringOrNull(json, 'image_url') ??
          _readStringOrNull(json, 'imageUrl') ??
          _readStringOrNull(json, 'photo_url'),
      photo: _decodePhoto(json['image'] ?? json['photo']),
      latitude: _readDouble(json, ['latitude', 'lat']),
      longitude: _readDouble(json, ['longitude', 'lng', 'lon']),
    );
  }

  static int _readId(Map<String, dynamic> json) {
    for (final key in const ['id', 'complaint_id', 'complaintId']) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final digits = RegExp(r'\d+').firstMatch(value);
        if (digits != null) return int.parse(digits.group(0)!);
      }
    }
    throw const ComplaintApiException('Complaint is missing an id.');
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String? fallback,
  }) {
    for (final key in keys) {
      final value = _readStringOrNull(json, key);
      if (value != null && value.isNotEmpty) return value;
    }

    if (fallback != null) return fallback;

    throw ComplaintApiException('Complaint is missing "${keys.first}".');
  }

  static String? _readStringOrNull(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static Uint8List? _decodePhoto(dynamic value) {
    if (value == null) return null;

    var text = value.toString().trim();
    if (text.isEmpty) return null;

    if (text.startsWith('data:')) {
      final comma = text.indexOf(',');
      if (comma == -1) return null;
      text = text.substring(comma + 1);
    }

    if (text.startsWith('http://') || text.startsWith('https://')) {
      return null;
    }

    try {
      return base64Decode(text);
    } catch (_) {
      return null;
    }
  }
}

/// Fetches complaints over HTTP using the `http` package.
class ComplaintApiService {
  /// Base URL of the complaints backend.
  ///
  /// Override per environment without touching code:
  /// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const String complaintsPath = '/api/complaints';
  static const Duration requestTimeout = Duration(seconds: 15);

  final http.Client? client;

  ComplaintApiService({this.client});

  Future<List<Complaint>> fetchComplaints() async {
    final uri = Uri.parse('$baseUrl$complaintsPath');
    final owned = client == null;
    final activeClient = client ?? http.Client();

    try {
      final response = await activeClient
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(requestTimeout);

      if (response.statusCode != 200) {
        throw ComplaintApiException(
          'Server returned ${response.statusCode}. '
          'Please try again in a moment.',
        );
      }

      return parseComplaints(response.body);
    } on ComplaintApiException {
      rethrow;
    } on TimeoutException {
      throw const ComplaintApiException(
        'The server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const ComplaintApiException(
        'No connection to the server. Check your network and retry.',
      );
    } on FormatException {
      throw const ComplaintApiException(
        'The server sent a response we could not read.',
      );
    } on http.ClientException {
      throw const ComplaintApiException(
        'The request failed. Please try again.',
      );
    } finally {
      if (owned) activeClient.close();
    }
  }

  /// Reads either a bare JSON array or an object wrapping the list under
  /// `data` / `complaints` / `results`.
  static List<Complaint> parseComplaints(String body) {
    final dynamic decoded;
    try {
      decoded = json.decode(body);
    } on FormatException {
      throw const ComplaintApiException(
        'The server sent a response we could not read.',
      );
    }

    final List<dynamic> raw;
    if (decoded is List) {
      raw = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final nested = decoded['data'] ??
          decoded['complaints'] ??
          decoded['results'];
      if (nested is List) {
        raw = nested;
      } else {
        throw const ComplaintApiException(
          'The server response did not contain a list of complaints.',
        );
      }
    } else {
      throw const ComplaintApiException(
        'The server response did not contain a list of complaints.',
      );
    }

    final complaints = <Complaint>[];

    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        complaints.add(Complaint.fromJson(entry));
      } else if (entry is Map) {
        complaints.add(Complaint.fromJson(Map<String, dynamic>.from(entry)));
      }
    }

    return complaints;
  }
}