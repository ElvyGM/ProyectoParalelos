import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();
  Future<String?> get token async =>
      (await SharedPreferences.getInstance()).getString('jwt');
  Future<Map<String, String>> headers() async => {
        'Content-Type': 'application/json',
        if (await token case final String t) 'Authorization': 'Bearer $t'
      };
  Future<dynamic> get(String path) async => _decode(await client
      .get(Uri.parse('${AppConfig.apiUrl}$path'), headers: await headers()));
  Future<dynamic> post(String path, Map<String, dynamic> body) async =>
      _decode(await client.post(Uri.parse('${AppConfig.apiUrl}$path'),
          headers: await headers(), body: jsonEncode(body)));
  Future<dynamic> put(String path, Map<String, dynamic> body) async =>
      _decode(await client.put(Uri.parse('${AppConfig.apiUrl}$path'),
          headers: await headers(), body: jsonEncode(body)));
  Future<void> delete(String path) async {
    _decode(await client.delete(Uri.parse('${AppConfig.apiUrl}$path'),
        headers: await headers()));
  }

  Future<dynamic> upload(String path, String filePath) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('${AppConfig.apiUrl}$path'));
    if (await token case final String t) {
      request.headers['Authorization'] = 'Bearer $t';
    }
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    return _decode(await http.Response.fromStream(await request.send()));
  }

  dynamic _decode(http.Response r) {
    final data = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException(data is Map
          ? (data['message'] ?? 'Error ${r.statusCode}').toString()
          : 'Error ${r.statusCode}');
    }
    return data;
  }
}
