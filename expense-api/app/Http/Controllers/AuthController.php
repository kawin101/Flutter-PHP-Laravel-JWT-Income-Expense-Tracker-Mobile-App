<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // กำหนดว่าไม่ต้องเช็ค Token สำหรับการ login และ register
    // (เพราะยังไม่มี Token จะเอาอะไรมาเช็คจริงไหมครับ 555)
    public function __construct()
    {
        // ใน Laravel 11 บางที middleware จะถูกย้ายไปที่ Route แทน
        // แต่ใส่ไว้ตรงนี้เพื่อความชัวร์สำหรับเวอร์ชั่นเก่าๆ
    }

    // 1. ฟังก์ชัน Register (สมัครสมาชิก)
    public function register(Request $request) {
        // ตรวจสอบข้อมูลที่ส่งมา
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|between:2,100',
            'email' => 'required|string|email|max:100|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if($validator->fails()){
            return response()->json($validator->errors()->toJson(), 400);
        }

        // สร้าง User ใหม่ลง Database
        $user = User::create(array_merge(
                    $validator->validated(),
                    ['password' => bcrypt($request->password)] // เข้ารหัสรหัสผ่าน
                ));

        return response()->json([
            'message' => 'User successfully registered',
            'user' => $user
        ], 201);
    }

    // 2. ฟังก์ชัน Login (เข้าสู่ระบบ)
    public function login(Request $request) {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // ตรวจสอบ email/password ถ้าไม่ถูกจะคืนค่า false
        if (! $token = Auth::attempt($validator->validated())) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // ถ้าถูก ส่ง Token กลับไป
        return $this->createNewToken($token);
    }

    // 3. ฟังก์ชัน Logout
    public function logout() {
        Auth::logout();
        return response()->json(['message' => 'User successfully signed out']);
    }

    // 4. ฟังก์ชันดูข้อมูลตัวเอง (User Profile)
    public function userProfile() {
        return response()->json(Auth::user());
    }

    // 5. ฟังก์ชัน Refresh Token (ขอ Token ใหม่เมื่ออันเก่าหมดอายุ)
    public function refresh() {
        return $this->createNewToken(Auth::refresh());
    }

    // ฟังก์ชันช่วยจัดรูปแบบ JSON เวลาส่ง Token กลับ
    protected function createNewToken($token){
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
            'user' => auth()->user()
        ]);
    }
}