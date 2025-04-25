# 🍅 HỆ THỐNG NHẬN DIỆN BỆNH TRÊN CÂY CÀ CHUA BẰNG HÌNH ẢNH

Ứng dụng nhận diện bệnh cây cà chua được xây dựng bằng Flutter, kết nối với backend YOLOv12 Nano (FastAPI) để quét ảnh lá cây và dự đoán bệnh.

## 🔗 Liên kết dự án

🧠 **Backend (FastAPI + YOLOv12 Nano):**  
👉 [Tomato Disease Detection Backend](https://github.com/aresu-1704/tomato-disease-detect_backend-yolov12)

💻 **Frontend (Flutter):**  
👉 [Tomato Disease Detection Frontend](https://github.com/aresu-1704/tomato_detect_app_frontend)

---

## 📌 Mô tả

Hệ thống nhận diện bệnh trên cây cà chua gồm **2 thành phần chính**:

- 📱 **Ứng dụng di động Flutter (Frontend):**  
  Giúp người dùng dễ dàng chụp ảnh lá cây, gửi ảnh lên server và hiển thị kết quả dự đoán. Giao diện thân thiện, dễ sử dụng cho cả nông dân và kỹ thuật viên.

- 🧠 **Hệ thống phân tích bệnh (Backend - FastAPI + YOLOv12 Nano):**  
  Nhận ảnh từ người dùng, chạy mô hình học sâu (YOLOv12 Nano) để xác định vùng lá bệnh và phân loại loại bệnh (mốc sương, xoăn lá, đốm vi khuẩn, v.v.).

### ✅ Các tính năng nổi bật:

- **Chụp ảnh hoặc chọn ảnh lá cây từ thư viện.**
- **Tự động khoanh vùng vùng bệnh bằng mô hình YOLOv12.**
- **Dự đoán loại bệnh chính xác bằng AI.**
- **Hiển thị kết quả trực quan và dễ hiểu.**
- **Lưu lịch sử ảnh.**

### 🎯 Mục tiêu dự án

Hỗ trợ nông dân và kỹ thuật viên nông nghiệp **phát hiện sớm** và **xử lý kịp thời** các loại bệnh thường gặp trên cây cà chua, giúp **giảm thiểu thiệt hại mùa vụ**, tăng hiệu quả sản xuất.

---

### 🖼️ Giao diện ứng dụng

#### 🔐 Xác thực người dùng
| Đăng nhập | Đăng ký | Quên mật khẩu | Nhập mã OTP | Khôi phục mật khẩu |
|----------|---------|----------------|-------------|---------------------|
| ![](images/login.png) | ![](images/register.png) | ![](images/forget-password.png) | ![](images/verify-otp.png) | ![](images/reset-password.png) |

---

#### 🌿 Nhận diện bệnh cây
| Giao diện quét bằng camera hoặc Upload ảnh từ thư viện | Kết quả dự đoán |
|----------------------------|-------------------|
| ![](images/camera-upload.png) | ![](images/predict-result.png) |

---

#### 📜 Lịch sử & chi tiết dự đoán
| Danh sách lịch sử |
|-------------------|
| ![](images/history.png) |



