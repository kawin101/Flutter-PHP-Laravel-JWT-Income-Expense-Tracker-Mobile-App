<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Transaction;
use Illuminate\Support\Facades\Validator;

class TransactionController extends Controller
{
    // 1. ดูรายการทั้งหมด (GET)
    public function index()
    {
        // ดึงข้อมูลเฉพาะของ User ที่ Login อยู่ เรียงตามวันที่ล่าสุด
        $transactions = auth()->user()->transactions()
            ->orderBy('transaction_date', 'desc')
            ->get();
        return response()->json($transactions);
    }

    // 2. เพิ่มรายการใหม่ (POST)
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:income,expense',
            'amount' => 'required|numeric',
            'category' => 'required|string',
            'transaction_date' => 'required|date',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        // สร้างข้อมูล โดยผูกกับ User ปัจจุบันอัตโนมัติ
        $transaction = auth()->user()->transactions()->create($validator->validated());

        return response()->json([
            'message' => 'Transaction created successfully',
            'data' => $transaction
        ], 201);
    }

    // 3. ดูรายละเอียดรายการเดียว (GET {id})
    public function show($id)
    {
        $transaction = auth()->user()->transactions()->find($id);

        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        return response()->json($transaction);
    }

    // 4. แก้ไขรายการ (PUT {id})
    public function update(Request $request, $id)
    {
        $transaction = auth()->user()->transactions()->find($id);

        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'type' => 'in:income,expense',
            'amount' => 'numeric',
            'category' => 'string',
            'transaction_date' => 'date',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        $transaction->update($validator->validated());

        return response()->json([
            'message' => 'Transaction updated successfully',
            'data' => $transaction
        ]);
    }

    // 5. ลบรายการ (DELETE {id})
    public function destroy($id)
    {
        $transaction = auth()->user()->transactions()->find($id);

        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        $transaction->delete();

        return response()->json(['message' => 'Transaction deleted successfully']);
    }
}