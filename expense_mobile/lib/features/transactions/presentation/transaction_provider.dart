import 'package:expense_mobile/features/transactions/data/transaction_model.dart';
import 'package:expense_mobile/features/transactions/data/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// สร้าง Provider แบบ AutoDispose (ปิดหน้านี้แล้วเคลียร์ข้อมูลทิ้ง เพื่อโหลดใหม่เมื่อเข้ามาใหม่)
final transactionListProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  // เรียก Repository ให้ไปดึงข้อมูล
  return ref.read(transactionRepositoryProvider).getTransactions();
});