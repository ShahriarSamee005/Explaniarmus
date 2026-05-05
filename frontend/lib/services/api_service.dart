// api_service.dart
// All backend API calls
// Place this in: frontend/lib/services/api_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/result_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // ── TEXT ──────────────────────────────────────
  static Future<SimplifyResult> simplifyText(
      String text, bool includeBangla) async {
    final uri = Uri.parse('$baseUrl/simplify-text');
    final response = await http
        .post(
          uri,
          body: {
            'text': text,
            'bangla': includeBangla.toString(),
          },
        )
        .timeout(const Duration(minutes: 3));

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return SimplifyResult.fromJson(jsonDecode(response.body));
  }

  // ── IMAGE ─────────────────────────────────────
  static Future<SimplifyResult> simplifyImageBytes(
      Uint8List bytes, String filename, bool includeBangla) async {
    final uri = Uri.parse('$baseUrl/simplify-image');

    final request = http.MultipartRequest('POST', uri)
      ..fields['bangla'] = includeBangla.toString()
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ));

    final streamedResponse =
        await request.send().timeout(const Duration(minutes: 5));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return SimplifyResult.fromJson(jsonDecode(response.body));
  }

  // ── PDF ───────────────────────────────────────
  static Future<SimplifyResult> simplifyPdfBytes(
      Uint8List bytes, String filename, bool includeBangla) async {
    final uri = Uri.parse('$baseUrl/simplify-pdf');

    final request = http.MultipartRequest('POST', uri)
      ..fields['bangla'] = includeBangla.toString()
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType('application', 'pdf'),
      ));

    final streamedResponse =
        await request.send().timeout(const Duration(minutes: 5));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return SimplifyResult.fromJson(jsonDecode(response.body));
  }
}