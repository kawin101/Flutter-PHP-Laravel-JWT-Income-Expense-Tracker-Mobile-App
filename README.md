# Flutter-PHP-Laravel-JWT-Income-Expense-Tracker-Mobile-App

## 📸 Screenshots

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/6aa07cc1-22e2-4a64-87bd-2a26ff930711" width="300" /></td>
    <td><img src="https://github.com/user-attachments/assets/8a7fa98e-f546-4bf5-99bd-fbea0838ec70" width="300" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/08b734e6-f450-47b1-9e90-bd5911f4276a" width="300" /></td>
    <td><img src="https://github.com/user-attachments/assets/752ab85c-b9ee-4cbc-8e63-4e7e4557ce4e" width="300" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/19cd1fe0-3b2d-439d-9746-4adeb4ae852f" width="300" /></td>
    <td><img src="https://github.com/user-attachments/assets/bad79cbb-0fd3-4737-9804-cff76065e3a0" width="300" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/0bdf8986-0eda-4db2-bece-e2e367d12ea4" width="300" /></td>
    <td></td>
  </tr>
</table>

---

## ✨ Features
- 🔐 **JWT Authentication** (Register, Login, Logout)
- 💸 **Income & Expense Tracking**
- 🏷️ **Category Management**
- 📊 **Dashboard & Analytics**
- 👤 **User Profile & Settings**
- 📱 **Cross-platform Flutter App (iOS & Android)**

# 🛠 Installation & Setup Guide

โปรเจกต์นี้มี 2 ส่วน  
- **Flutter App (Frontend)**
- **Laravel API (Backend)**

ด้านล่างเป็นคำแนะนำแบบละเอียดสำหรับการติดตั้งครั้งแรก

# 1️⃣ Prerequisites

ติดตั้งโปรแกรมต่อไปนี้ก่อน:

| Tool | Required |
|------|----------|
| PHP | 8.0+ |
| Composer | Latest |
| MySQL / MariaDB | Required |
| Local Server (XAMPP / MAMP / Laragon) | Required |
| Flutter SDK | Latest Stable |
| Android Studio / Xcode | For mobile emulator |

---

# 2️⃣ Backend Setup (Laravel API)

### 📂 Navigate to backend folder

```bash
cd expense-api
````

### 🔧 Install composer dependencies

```bash
composer install
```

### 📄 Create `.env` file

```bash
cp .env.example .env
```

### 🗄 Configure database in `.env`

```dotenv
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=income_expense_db
DB_USERNAME=root
DB_PASSWORD=
```

### 🔑 Generate keys

```bash
php artisan key:generate
php artisan jwt:secret
```

### 🧱 Run migrations

```bash
php artisan migrate --seed
```

### ▶️ Start API server

```bash
php artisan serve
```

API will be available at:

```
http://127.0.0.1:8000
```

---

# 3️⃣ Frontend Setup (Flutter)

### 📂 Navigate to app folder

```bash
cd ../expense_mobile
```

### 📦 Install dependencies

```bash
flutter pub get
```

### 🔗 Configure API base URL

เปิดไฟล์:

```
lib/config/api_config.dart
```

เปลี่ยน `baseUrl` ตามอุปกรณ์ที่ใช้:

| Device           | Base URL                                               |
| ---------------- | ------------------------------------------------------ |
| Android Emulator | [http://10.0.2.2:8000/api](http://10.0.2.2:8000/api)   |
| iOS Simulator    | [http://127.0.0.1:8000/api](http://127.0.0.1:8000/api) |
| Physical Device  | http://YOUR_LOCAL_IP:8000/api                          |

หา Local IP ด้วยคำสั่ง:

```bash
ipconfig (Windows)
ifconfig (Mac)
```

### ▶️ Run Flutter App

```bash
flutter run
```

---

# 📘 API Documentation (Swagger-like)

Base URL:

```
http://127.0.0.1:8000/api
```

## 🔐 Auth Endpoints

| Endpoint         | Method | Auth |
| ---------------- | ------ | ---- |
| `/auth/register` | POST   | ❌    |
| `/auth/login`    | POST   | ✅    |
| `/auth/logout`   | POST   | ✅    |

### Example: Register

**URL** `http://expense-api.test/api/auth/register`

**POST** `/auth/register`

```json
{
    "name": "Test User",
    "email": "test@gmail.com",
    "password": "password123"
}
```

---

### Example: Login

**POST** `/auth/login`

```json
{
    "email": "test@gmail.com",
    "password": "password123"
}
```

### Authorization Header (Required)

```
Authorization: Bearer <TOKEN>
```

---

# 💸 Transaction Endpoints

| Endpoint             | Method | Description |
| -------------------- | ------ | ----------- |
| `/transactions`      | GET    | Get all     |
| `/transactions`      | POST   | Create      |
| `/transactions/{id}` | PUT    | Update      |
| `/transactions/{id}` | DELETE | Delete      |

### Create transaction (Example)

**Method:** ```POST```

**URL:** ```http://expense-api.test/api/transactions```

```json
{
    "type": "expense",
    "amount": 150.00,
    "category": "Food",
    "description": "Lunch at KFC",
    "transaction_date": "2025-11-19"
}
```

---

# 🏷 Category Endpoints

| Endpoint      | Method | Description |
| ------------- | ------ | ----------- |
| `/categories` | GET    | List        |
| `/categories` | POST   | Create      |

---

# 🤝 Contributing

Pull Requests are welcome.
Open Issues if you find bugs or want new features.

---

# 📄 License

MIT License

