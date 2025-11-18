import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Import Router ที่เราเพิ่งสร้าง
import 'core/router/router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. ดึง routerConfig มาจาก Riverpod provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        textTheme: GoogleFonts.kanitTextTheme(),
      ),
      
      // 3. ใส่ routerConfig เข้าไป
      routerConfig: router,
    );
  }
}