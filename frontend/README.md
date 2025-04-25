# 🍅 Tomato Disease Detection App (Frontend)

Ứng dụng nhận diện bệnh cây cà chua được xây dựng bằng Flutter, kết nối với backend YOLOv12 Nano (FastAPI) để quét ảnh lá cây và dự đoán bệnh.

## 🔗 Liên kết dự án

🧠 **Backend (FastAPI + YOLOv12 Nano):**  
👉 [Tomato Disease Detection Backend](https://github.com/aresu-1704/tomato-disease-detect_backend-yolov12)

💻 **Frontend (Flutter):**  
👉 [Tomato Disease Detection Frontend](https://github.com/aresu-1704/tomato_detect_app_frontend)

---

## 📌 Mô tả

Ứng dụng frontend này được xây dựng bằng Flutter để cung cấp giao diện người dùng, cho phép người dùng:
- Đăng nhập, đăng ký và khôi phục mật khẩu.
- Chụp ảnh lá cây và gửi ảnh đến backend để nhận diện bệnh.
- Xem lịch sử các lần phát hiện bệnh.

Ứng dụng này kết nối với backend sử dụng FastAPI và YOLOv12 Nano để xử lý ảnh và trả về kết quả dự đoán bệnh cây cà chua.

## 🚀 Các tính năng chính

- **🔒 Đăng nhập & Đăng ký:** Người dùng có thể đăng nhập vào ứng dụng hoặc tạo tài khoản mới.
- **🔑 Khôi phục mật khẩu:** Tính năng cho phép người dùng khôi phục mật khẩu của mình qua email.
- **📸 Chụp ảnh lá cây:** Người dùng có thể chụp ảnh lá cây cà chua bằng camera.
- **🧠 Nhận diện bệnh cây:** Ảnh sẽ được gửi đến backend và nhận kết quả dự đoán bệnh cây.
- **📜 Xem lịch sử phát hiện bệnh:** Người dùng có thể xem lại lịch sử các lần phát hiện bệnh từ trước.

---

## 🛠 Cài đặt và cấu hình

### Yêu cầu

- Flutter SDK (phiên bản mới nhất)
- Dart SDK
- Trình giả lập Android hoặc thiết bị thực để chạy ứng dụng.

### Cài đặt

1. Clone repository frontend:

   ```bash
   #Clone repo
   git clone https://github.com/aresu-1704/tomato_detect_app_frontend.git
   
   #Chuyển vào thư mục dự án
   cd tomato_detect_app_frontend
   
   #Cài đặt các phụ thuộc
   flutter pub get
   ```
2. Cấu hình API:

Cấu hình API url trong `lib/constants/api_constant.dart`:

   ```bash
      #Cấu hình URL API backend
      static const String baseUrl = <YOUR_API_URL>;
   ```

