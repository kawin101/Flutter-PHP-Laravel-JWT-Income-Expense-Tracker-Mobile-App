import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// สร้าง Provider ให้เรียกใช้ได้ทั่วแอพ
final localStorageProvider = Provider((ref) => LocalStorage());

class LocalStorage {
  static const _tokenKey = 'auth_token';

  // บันทึก Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // อ่าน Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ลบ Token (ตอน Logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}