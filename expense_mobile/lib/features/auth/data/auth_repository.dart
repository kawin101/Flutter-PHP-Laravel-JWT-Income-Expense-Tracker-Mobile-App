import 'package:dio/dio.dart';
import 'package:expense_mobile/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider); // เรียกใช้ Dio ที่เราสร้างไว้
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  // ฟังก์ชัน Login
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      // รับ access_token กลับไป
      return response.data['access_token'];
    } on DioException catch (e) {
      // ถ้า Error ให้โยนข้อความกลับไป
      throw e.response?.data['error'] ?? 'Login failed';
    }
  }

  // ฟังก์ชัน Register
  Future<void> register(String name, String email, String password) async {
    try {
      await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Registration failed';
    }
  }
}