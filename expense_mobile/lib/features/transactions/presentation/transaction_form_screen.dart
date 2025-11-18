import 'package:expense_mobile/features/transactions/data/transaction_model.dart';
import 'package:expense_mobile/features/transactions/presentation/add_transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionModel? itemToEdit;
  const TransactionFormScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // ตัวแปรเก็บค่าในฟอร์ม
  String _type = 'expense'; // ค่าเริ่มต้น: รายจ่าย
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // ถ้ามีการส่งข้อมูลมาให้แก้ไข
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _type = item.type;
      _amountController.text = item.amount.toString();
      _categoryController.text = item.category;
      _descController.text = item.description ?? '';
      _selectedDate = item.transactionDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ฟังสถานะการบันทึก
    ref.listen(addTransactionControllerProvider, (previous, next) {
      if (next is AsyncData) {
        // ถ้าบันทึกสำเร็จ -> ปิดหน้านี้กลับไป Dashboard
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('บันทึกรายการแล้ว!'),
              backgroundColor: Colors.green),
        );
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาด: ${next.error}'),
              backgroundColor: Colors.red),
        );
      }
    });

    final isLoading = ref.watch(addTransactionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มรายการใหม่')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. เลือกประเภท (รายรับ / รายจ่าย)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'expense',
                      label: Text('รายจ่าย'),
                      icon: Icon(Icons.money_off)),
                  ButtonSegment(
                      value: 'income',
                      label: Text('รายรับ'),
                      icon: Icon(Icons.attach_money)),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  // เปลี่ยนสีตามประเภทที่เลือก
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _type == 'expense'
                          ? Colors.red.shade100
                          : Colors.green.shade100;
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // 2. จำนวนเงิน
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'จำนวนเงิน',
                  border: OutlineInputBorder(),
                  prefixText: '฿ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกจำนวนเงิน';
                  }
                  if (double.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขเท่านั้น';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. หมวดหมู่
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่ (เช่น อาหาร, เดินทาง)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (val) => val!.isEmpty ? 'ระบุหมวดหมู่' : null,
              ),
              const SizedBox(height: 16),

              // 4. วันที่ (กดแล้วเด้งปฏิทิน)
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'วันที่',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // 5. รายละเอียด (ไม่บังคับ)
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียดเพิ่มเติม (ถ้ามี)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 30),

              // ปุ่มบันทึก
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('บันทึกรายการ',
                          style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(addTransactionControllerProvider.notifier);

      final type = _type;
      final amount = double.parse(_amountController.text);
      final category = _categoryController.text;
      final date = _selectedDate;
      final description = _descController.text;

      if (widget.itemToEdit == null) {
        // ถ้าไม่มี itemToEdit -> ทำการสร้างใหม่ (Add)
        controller.addTransaction(
          type: type,
          amount: amount,
          category: category,
          transactionDate: date,
          description: description,
        );
      } else {
        // ถ้ามี itemToEdit -> ทำการแก้ไข (Update)
        controller.updateTransaction(
          id: widget.itemToEdit!.id, // ส่ง ID เข้าไปด้วย
          type: type, amount: amount, category: category, date: date,
          description: description,
        );
      }
    }
  }
}
