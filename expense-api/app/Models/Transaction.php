<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'amount',
        'category',
        'description',
        'transaction_date',
        'user_id' // อย่าลืมใส่ตัวนี้
    ];

    // Transaction เป็นของ User 1 คน
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}