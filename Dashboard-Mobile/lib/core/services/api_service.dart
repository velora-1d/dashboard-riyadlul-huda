import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dashboard.riyadlulhuda.my.id/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  ApiService._internal();

  Dio get client => _dio;

  Future<void> setToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _dio.options.headers.remove('Authorization');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role'); // Clear role as well
  }

  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return token;
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    Options? options;
    if (data is FormData) {
      options = Options(
        contentType: 'multipart/form-data',
      );
    }
    return await _dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
