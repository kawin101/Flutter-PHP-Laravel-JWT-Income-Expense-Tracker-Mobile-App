import 'package:expense_mobile/features/transactions/data/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';

final addTransactionControllerProvider =
    StateNotifierProvider<AddTransactionController, AsyncValue<void>>((ref) {
  return AddTransactionController(ref);
});

class AddTransactionController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AddTransactionController(this.ref) : super(const AsyncValue.data(null));

  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    required DateTime transactionDate,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. ยิง API บันทึก
      await ref.read(transactionRepositoryProvider).createTransaction(
            type: type,
            amount: amount,
            category: category,
            transactionDate: transactionDate,
            description: description,
          );

      // 2. ไฮไลท์สำคัญ! สั่งให้หน้า Dashboard โหลดข้อมูลใหม่ (Refresh)
      // เมื่อเรากลับไปหน้าเดิม ข้อมูลใหม่จะโผล่ขึ้นมาทันที
      ref.invalidate(transactionListProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ฟังก์ชัน Update (เพิ่มต่อท้ายใน class AddTransactionController)
  Future<void> updateTransaction({
    required int id, // รับ id มาด้วย
    required String type,
    required double amount,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updateData = {
        'type': type,
        'amount': amount,
        'category': category,
        'transaction_date': date.toIso8601String().split('T')[0],
        'description': description,
      };

      await ref
          .read(transactionRepositoryProvider)
          .updateTransaction(id, updateData);

      // สั่งให้ List โหลดใหม่
      ref.invalidate(transactionListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
