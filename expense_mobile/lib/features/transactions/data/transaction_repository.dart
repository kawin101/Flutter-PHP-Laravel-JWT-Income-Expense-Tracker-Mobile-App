import 'package:dio/dio.dart';
import 'package:expense_mobile/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_model.dart';

final transactionRepositoryProvider = Provider((ref) {
  return TransactionRepository(ref.read(dioProvider));
});

class TransactionRepository {
  final Dio _dio;

  TransactionRepository(this._dio);

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get('/transactions');
      final List data = response.data;
      // แปลง List JSON เป็น List TransactionModel
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.message ?? 'Something went wrong';
    }
  }

  // ฟังก์ชันเพิ่มรายการใหม่
  Future<void> createTransaction({
    required String type,
    required double amount,
    required String category,
    required DateTime transactionDate,
    String? description,
  }) async {
    try {
      await _dio.post('/transactions', data: {
        'type': type,
        'amount': amount,
        'category': category,
        'transaction_date': transactionDate
            .toIso8601String()
            .split('T')[0], // แปลงเป็น yyyy-MM-dd
        'description': description,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create transaction';
    }
  }

  // ฟังก์ชันแก้ไขรายการ
  Future<void> updateTransaction(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/transactions/$id', data: data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update transaction';
    }
  }

  // ฟังก์ชันลบรายการ
  Future<void> deleteTransaction(int id) async {
    try {
      await _dio.delete('/transactions/$id');
    } on DioException catch (e) {
      throw e.message ?? 'Failed to delete transaction';
    }
  }
}
