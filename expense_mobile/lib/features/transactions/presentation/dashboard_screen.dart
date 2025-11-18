import 'package:expense_mobile/core/storage/local_storage.dart';
import 'package:expense_mobile/features/transactions/data/transaction_repository.dart';
import 'package:expense_mobile/features/transactions/presentation/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; 


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. เฝ้าดูข้อมูลจาก Provider
    final transactionState = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายรับ-รายจ่าย'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // ปุ่ม Refresh: สั่งให้โหลดข้อมูลใหม่
              ref.invalidate(transactionListProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(localStorageProvider).clearToken();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      // 2. ใช้ .when เพื่อจัดการ 3 สถานะ (ข้อมูลมาแล้ว / กำลังโหลด / Error)
      body: transactionState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
                child: Text('ยังไม่มีรายการ กดปุ่ม + เพื่อเพิ่มเลย'));
          }

          // 3. แสดงรายการแบบ List
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final item = transactions[index];
              final isExpense = item.type == 'expense';

              // ใช้ Dismissible เพื่อทำ Swipe-to-Delete
              return Dismissible(
                key: ValueKey(item.id), // Key ต้องเป็น unique
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) {
                  // ให้ขึ้นกล่อง Confirm ก่อนลบ
                  return showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('ยืนยัน'),
                      content: const Text('คุณต้องการลบรายการนี้หรือไม่?'),
                      actions: [
                        TextButton(
                            onPressed: () => context.pop(false),
                            child: const Text('ยกเลิก')),
                        TextButton(
                            onPressed: () => context.pop(true),
                            child: const Text('ลบ',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  // เมื่อยืนยันแล้ว ทำการลบ
                  await ref
                      .read(transactionRepositoryProvider)
                      .deleteTransaction(item.id);
                      
                  // สั่งให้ List โหลดใหม่ (สำคัญมาก!)
                  ref.invalidate(transactionListProvider);
                  
                  // ถ้าสำเร็จจะแสดง SnackBar (แจ้งเตือนสั้นๆ)
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ลบรายการ ${item.category} แล้ว'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },

                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    // ------------------------------------------------
                    // FIX: เพิ่ม onTap สำหรับ Tap-to-Edit
                    // ------------------------------------------------
                    onTap: () {
                      // ไปที่ /form โดยส่ง object itemToEdit ไปด้วย
                      context.push('/form', extra: item); 
                    },
                    // ------------------------------------------------
                    
                    leading: CircleAvatar(
                      backgroundColor: isExpense
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      child: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(item.category,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${DateFormat('dd MMM yyyy').format(item.transactionDate)}\n${item.description ?? ""}',
                    ),
                    trailing: Text(
                      '${isExpense ? "-" : "+"}${item.amount}',
                      style: TextStyle(
                        color: isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ไปที่ /form โดยไม่ส่ง object (เป็นการสร้างใหม่)
          context.push('/form'); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}