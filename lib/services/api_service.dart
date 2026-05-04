import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String apiKey;
  final http.Client client;

  ApiService({
    required this.baseUrl,
    required this.apiKey,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: {'token': apiKey},
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getWithParams(
    String endpoint,
    Map<String, String> params,
  ) async {
    final allParams = {...params, 'token': apiKey};
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: allParams,
    );
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: {'token': apiKey},
    );
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  void dispose() {
    client.close();
  }
}
