import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const baseUrl = 'https://dashboard.riyadlulhuda.my.id/api';

  // 1. Login
  print('--- 1. Logging in ---');
  final loginUrl = Uri.parse('$baseUrl/parent/login');
  final loginResp = await http.post(
    loginUrl,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({
      'nama_santri':
          'Mahin Utsman Nawawi', // Ensure exact match or close enough
      'tanggal_lahir': '2001-06-20'
    }),
  );

  print('Login Status: ${loginResp.statusCode}');
  print('Login Body: ${loginResp.body}');

  if (loginResp.statusCode != 200) {
    print('Login Failed!');
    return;
  }

  final loginData = jsonDecode(loginResp.body);
  final token = loginData['data']['token'];
  print('Token: ${token.substring(0, 10)}...'); // Truncate for safety

  // 2. Fetch Sekretaris Santri (This is what EraporScreen calls)
  print('\n--- 2. Fetching /sekretaris/santri ---');
  final santriUrl = Uri.parse('$baseUrl/sekretaris/santri');
  final santriResp = await http.get(
    santriUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  print('Santri Fetch Status: ${santriResp.statusCode}');
  if (santriResp.statusCode == 500) {
    print('Error Body Start: ${santriResp.body.substring(0, 800)}');
  } else {
    print('Santri Fetch Body: ${santriResp.body}');
  }

  // 3. Check /parent/me
  print('\n--- 3. Fetching /parent/me ---');
  final meUrl = Uri.parse('$baseUrl/parent/me');
  final meResp = await http.get(
    meUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  print('Me Status: ${meResp.statusCode}');
  print('Me Body: ${meResp.body}');
}
