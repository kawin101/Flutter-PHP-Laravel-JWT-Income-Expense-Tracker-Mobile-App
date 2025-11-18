<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // ผูกกับ User (ใครเป็นคนจด)
            $table->enum('type', ['income', 'expense']); // ประเภท: รายรับ หรือ รายจ่าย
            $table->decimal('amount', 10, 2); // จำนวนเงิน (ทศนิยม 2 ตำแหน่ง)
            $table->string('category'); // หมวดหมู่ (เช่น อาหาร, เดินทาง)
            $table->string('description')->nullable(); // รายละเอียด (ไม่ใส่ก็ได้)
            $table->date('transaction_date'); // วันที่ทำรายการ
            $table->timestamps(); // create_at, updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
