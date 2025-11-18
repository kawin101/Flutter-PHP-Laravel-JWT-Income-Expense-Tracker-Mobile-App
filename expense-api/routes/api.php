<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TransactionController;

// กลุ่ม Route สำหรับ Authentication
Route::group([
    'middleware' => 'api',
    'prefix' => 'auth' // URL จะขึ้นต้นด้วย /api/auth/xxx
], function ($router) {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:api');
    Route::post('/refresh', [AuthController::class, 'refresh'])->middleware('auth:api');
    Route::get('/user-profile', [AuthController::class, 'userProfile'])->middleware('auth:api');
});

Route::middleware(['auth:api'])->group(function () {
    Route::resource('transactions', TransactionController::class);
});