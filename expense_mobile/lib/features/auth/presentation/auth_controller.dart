import 'package:expense_mobile/core/storage/local_storage.dart';
import 'package:expense_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier ใช้จัดการ State แบบ Asynchronous (Loading, Error, Success)
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<String?>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncValue.data(null));

  // ฟังก์ชันสมัครสมาชิก
  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // ยิง API Register
      await ref.read(authRepositoryProvider).register(name, email, password);

      // ถ้าสำเร็จ (Backend ไม่ได้คืน Token) เราจะไปให้ผู้ใช้ Login ต่อ
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String email, String password) async {
    // 1. เริ่มโหลด (หมุนติ้วๆ)
    state = const AsyncValue.loading();

    try {
      // 2. ยิง API Login
      final token =
          await ref.read(authRepositoryProvider).login(email, password);

      debugPrint('API CALL SUCCESS. RECEIVED TOKEN: $token'); 

      // 3. ถ้าผ่าน บันทึก Token ลงเครื่อง
      await ref.read(localStorageProvider).saveToken(token);

      // 4. จบการทำงาน (Success)
      // 🛑 FIX: บรรทัดนี้ต้องส่ง token กลับไปใน State 
      state = AsyncValue.data(token); // ⬅️ เปลี่ยนจาก const AsyncValue.data(null)
    
    } catch (e, stack) {
      // 5. ถ้าพัง (Error)
      debugPrint('API CALL FAILED. Error: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  // ฟังก์ชันรีเซ็ตสถานะกลับเป็นปกติ (สำคัญมากในการป้องกัน State Bleeding)
  void resetState() {
    state = const AsyncValue.data(null);
  }
}
