# 🍅 Tomato Disease Detection API - YOLOv12 Nano (FastAPI)

Đây là backend API được xây dựng bằng [FastAPI](https://fastapi.tiangolo.com/) cho hệ thống **Nhận diện bệnh cây Cà Chua** bằng mô hình **YOLOv12 Nano**.

## 🔗 Liên kết dự án

- 🧠 **Backend (FastAPI + YOLOv12 Nano)**:  
  👉 [https://github.com/aresu-1704/tomato-disease-detect_backend-yolov12](https://github.com/aresu-1704/tomato-disease-detect_backend-yolov12.git)

- 💻 **Frontend (Flutter)**:  
  👉 [https://github.com/aresu-1704/tomato_detect_app_frontend](https://github.com/aresu-1704/tomato_detect_app_frontend.git)

---

## 🚀 Tính năng chính

### 🔐 Authentication
- `POST /auth/login`: Đăng nhập
- `POST /auth/register`: Đăng ký tài khoản
- `POST /auth/reset-password`: Đặt lại mật khẩu
- `POST /auth/send-otp`: Gửi mã OTP
- `POST /auth/verify-otp`: Xác minh mã OTP

### 🔬 Dự đoán bệnh cây cà chua
- `POST /predict/predict-image`: Tải ảnh lên để dự đoán bệnh lá cà chua

### 🧾 Lịch sử dự đoán
- `POST /disease-history/save`: Lưu lại lịch sử dự đoán bệnh
- `GET /disease-history/get-by-id/{user_id}`: Lấy lịch sử dự đoán theo `user_id`

---

## 🧠 Mô hình sử dụng
- **YOLOv12 Nano**: phát hiện lá bị bệnh cây cà chua (bounding box)
- Sau khi cắt vùng chứa lá bệnh, sử dụng CNN để phân loại loại bệnh cụ thể

---

## 🧰 Công nghệ
- `FastAPI` – backend framework
- `YOLOv12 Nano` – phát hiện lá bệnh
- `CNN` – phân loại bệnh
- `Pydantic`, `Uvicorn`, `PostgreSQL`

---

## 📦 Cài đặt Backend

### ⚙️ Yêu cầu:
- Python 3.11+
- pip

### 🧪 Các bước setup:

```bash

# Clone repo
git clone https://github.com/aresu-1704/tomato-disease-detect_backend-yolov12.git
cd tomato-disease-detect_backend-yolov12

# Tạo môi trường ảo
python -m venv venv
source venv/bin/activate  # Windows: .\venv\Scripts\activate

# Cài đặt thư viện
pip install -r requirements.txt

# Chạy server
uvicorn main:app --reload
```
---

## 🗃️ Cài đặt Cơ sở Dữ liệu

### ⚙️ Yêu cầu:
- PostgreSQL

### 🧪 Các bước setup:

```bash

#Chạy Script database
psql -U your_postgres_user -d your_database_name -f .DATABASE_SCHEMAS/postgreSQL_database.sql
```

## **⚠️ Lưu ý:**

- Đảm bảo bạn đã cài đặt PostgreSQL và đã tạo một cơ sở dữ liệu trống.

- Thay your_postgres_user bằng tên người dùng PostgreSQL của bạn.

- Thay your_database_name bằng tên cơ sở dữ liệu mà bạn muốn sử dụng.

