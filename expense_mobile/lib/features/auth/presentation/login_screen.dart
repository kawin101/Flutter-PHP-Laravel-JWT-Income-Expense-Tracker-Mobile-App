import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ตัวควบคุม Textbox
  final _emailController =
      TextEditingController(text: 'test@gmail.com'); // ใส่ค่า Default ไว้เทส
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ฟังก์ชันกดปุ่ม Login
  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // สั่ง Controller ให้ทำงาน
      ref.read(authControllerProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. ฟังสถานะ (Listen) เพื่อจัดการเปลี่ยนหน้า หรือแจ้งเตือน Error
    ref.listen<AsyncValue<String?>>(authControllerProvider, (previous, next) {
      // กรณีเจอ Error
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // กรณีสำเร็จ (Success)
      // *** เงื่อนไขใหม่: ต้องสำเร็จและมี Token อยู่ใน State ด้วย ***
      if (next is AsyncData && next.value != null && next.value!.isNotEmpty) {
      // if (next is AsyncData && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login สำเร็จ!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        context.go('/dashboard');
      }
    });

    // 2. ดูสถานะ (Watch) เพื่อเช็คว่ากำลังโหลดอยู่ไหม
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // โลโก้หรือหัวข้อ
                const Icon(Icons.account_balance_wallet,
                    size: 80, color: Colors.blueAccent),
                const SizedBox(height: 20),
                const Text(
                  'ยินดีต้อนรับกลับมา!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // ช่องกรอก Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกอีเมล';
                    return null;
                  },
                  enabled: !isLoading, // ล็อคห้ามพิมพ์ตอนโหลด
                ),
                const SizedBox(height: 16),

                // ช่องกรอก Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    return null;
                  },
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),

                // ปุ่ม Login
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('เข้าสู่ระบบ',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),

                // ปุ่มไปหน้าสมัครสมาชิก (ทำเป็นปุ่มหลอกไว้ก่อน)
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.push('/register');
                        },
                  child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
