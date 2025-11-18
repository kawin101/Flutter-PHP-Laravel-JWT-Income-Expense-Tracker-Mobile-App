import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. สร้าง Provider สำหรับ Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // ตั้งค่า Base URL (สำคัญ! ต้องเปลี่ยนตามเครื่องคุณ)
  // iOS Simulator: ใช้ http://127.0.0.1:8000 หรือ http://expense-api.test
  // Android Emulator: ใช้ http://10.0.2.2:8000
  dio.options.baseUrl = 'http://expense-api.test/api/'; 
  
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);

  // 2. ใส่ Interceptor เพื่อแนบ Token อัตโนมัติ
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // ดึง Token จากเครื่อง (เดี๋ยวเราทำส่วน Storage แยกอีกที)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      
      return handler.next(options);
    },
  ));

  return dio;
});