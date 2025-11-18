// ไฟล์: lib/features/auth/presentation/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).register(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. ฟังสถานะ (Listen) เพื่อจัดการ Error และการเปลี่ยนหน้า
    // ✅ FIX: เปลี่ยนเป็น AsyncValue<String?> เพื่อให้เข้ากันได้กับ Controller
    ref.listen<AsyncValue<String?>>(authControllerProvider, (previous, next) { 
      final controller = ref.read(authControllerProvider.notifier);

      // กรณีเจอ Error
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: Colors.red),
        );
      }

      // ✅ FIX: กรณีสำเร็จ (Success) - เช็คว่า State เป็น AsyncData และค่าเป็น null (หมายถึงมาจาก Register)
      if (next is AsyncData && next.value == null && !next.isLoading) { 
        
        // A. แสดง SnackBar ของ Registration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        // B. ล้างสถานะทันที เพื่อไม่ให้ Login Screen เห็น
        controller.resetState();

        // C. ไปหน้า Login
        context.go('/login');
      }
    });

    // 2. ดูสถานะ (Watch) เพื่อเช็คว่ากำลังโหลดอยู่ไหม
    final isLoading = ref.watch(authControllerProvider).isLoading;

    // ... ส่วน build ที่เหลือเหมือนเดิม ...
    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  'สร้างบัญชีใหม่',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // ช่องกรอก Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อ' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // ช่องกรอก Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'กรุณากรอกอีเมล' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // ช่องกรอก Password (พร้อมไอคอนลูกตา)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure, // ใช้ state ในการซ่อน
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน (อย่างน้อย 6 ตัว)',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      // เพิ่ม IconButton
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure; // สลับค่า state เมื่อกด
                        });
                      },
                    ),
                  ),
                  validator: (value) => value!.length < 6
                      ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว'
                      : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // ช่องยืนยันรหัสผ่าน (พร้อมไอคอนลูกตา)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isObscure, // ใช้ state เดียวกันกับช่องบน
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      // เพิ่ม IconButton
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure; // สลับค่า state เมื่อกด
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณายืนยันรหัสผ่าน';
                    }
                    // ตรวจสอบว่าตรงกับรหัสผ่านช่องแรกหรือไม่ (เงื่อนไขที่สำคัญ)
                    if (value != _passwordController.text) {
                      return 'รหัสผ่านทั้งสองช่องไม่ตรงกัน';
                    }
                    return null;
                  },
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),

                // ปุ่ม Register
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('สมัครสมาชิก',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),

                // ปุ่มกลับไป Login
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/login'),
                  child: const Text('มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}