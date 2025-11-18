import 'package:expense_mobile/features/auth/presentation/login_screen.dart';
import 'package:expense_mobile/features/auth/presentation/registration_screen.dart';
import 'package:expense_mobile/features/transactions/data/transaction_model.dart';
import 'package:expense_mobile/features/transactions/presentation/transaction_form_screen.dart';
import 'package:expense_mobile/features/transactions/presentation/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // กำหนดให้เริ่มต้นที่หน้า Login
    initialLocation: '/login',

    routes: [
      // เส้นทางหน้า Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // เพิ่มเส้นทางหน้า Register
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),

      // เส้นทางหน้า Dashboard (Home)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // เปลี่ยนชื่อ route เป็น /form (ใช้ได้ทั้ง Add และ Edit)
      GoRoute(
        path: '/form',
        name: 'transaction-form',
        builder: (context, state) {
          // ถ้ามี Object ส่งมา (เช่นการแก้ไข) ให้ดึงมาใช้
          final itemToEdit = state.extra as TransactionModel?;
          return TransactionFormScreen(
            itemToEdit: itemToEdit,
          ); // ส่งข้อมูลไปให้หน้า Form
        },
      ),
    ],
  );
});
