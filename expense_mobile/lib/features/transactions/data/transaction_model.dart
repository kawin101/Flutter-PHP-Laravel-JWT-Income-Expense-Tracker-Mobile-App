class TransactionModel {
  final int id;
  final String type; // 'income' หรือ 'expense'
  final double amount;
  final String category;
  final String? description;
  final DateTime transactionDate;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.description,
    required this.transactionDate,
  });

  // แปลงจาก JSON (Map) เป็น Object
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      // แปลง String/Int เป็น Double ให้ชัวร์
      amount: double.parse(json['amount'].toString()),
      category: json['category'],
      description: json['description'],
      transactionDate: DateTime.parse(json['transaction_date']),
    );
  }
}