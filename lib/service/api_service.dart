import 'dart:convert';

import 'package:app_5/encrypt_decrypt.dart';
import 'package:http/http.dart' as http;

class ApiService{
  final String baseUrl;

  ApiService({required this.baseUrl});

  // GET Method
  Future<http.Response> get(String endpoint) async => await http.get(Uri.parse('$baseUrl$endpoint'));

  // POST Method
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final encodeBody = json.encode(body);
    print("$baseUrl$endpoint");
    print('Json Body: $encodeBody');
    final encryptedBody = encryptAES(encodeBody);
    print('Encrypted Data: data: $encryptedBody');
    return await http.post(Uri.parse('$baseUrl$endpoint'), body: {'data': encryptedBody});
  }

}

