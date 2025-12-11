# Tomato Disease Detection App

Ứng dụng mobile phát hiện và chẩn đoán bệnh trên cây cà chua sử dụng công nghệ AI và Deep Learning.

## Mô tả

Ứng dụng giúp nông dân và người trồng cà chua có thể:
- Chụp ảnh hoặc tải ảnh lá cà chua lên hệ thống
- Nhận kết quả phân tích bệnh tự động với độ chính xác cao
- Xem thông tin chi tiết về bệnh được phát hiện (nguyên nhân, triệu chứng, cách điều trị)
- Lưu lịch sử các lần kiểm tra để theo dõi tình trạng cây trồng

## Tính năng chính

### Xác thực người dùng
- Đăng ký tài khoản
- Đăng nhập
- Quên mật khẩu và khôi phục qua OTP

### Phát hiện bệnh
- Chụp ảnh trực tiếp từ camera
- Tải ảnh từ thư viện
- Phân tích và nhận diện bệnh bằng AI
- Hiển thị kết quả với bounding box trên ảnh
- Thông tin chi tiết về từng loại bệnh

### Quản lý lịch sử
- Lưu trữ các lần phân tích
- Xem lại kết quả đã lưu
- Theo dõi diễn biến bệnh qua thời gian

## Công nghệ sử dụng

### Frontend (Mobile App)
- **Framework**: Flutter 3.7.0+
- **Language**: Dart
- **State Management**: Stateful Widgets
- **Dependency Injection**: GetIt
- **UI/UX**: 
  - Custom gradient backgrounds
  - Animate Do cho animations
  - Shimmer cho loading states
  - Custom notification system

### Backend API
- **Framework**: FastAPI (Python)
- **AI Model**: YOLO (YOLOv10n custom) cho Object Detection
- **Image Processing**: OpenCV, PIL
- **Database**: MongoDB

### Các package chính
- `http`: Giao tiếp với API
- `image_picker`: Chọn ảnh từ gallery/camera
- `camera`: Chụp ảnh trực tiếp
- `shared_preferences`: Lưu trữ local
- `get_it`: Service locator pattern
- `animate_do`: Animations
- `shimmer`: Loading effects

## Cấu trúc dự án

```
lib/
├── core/
│   └── service_locator.dart          # Dependency injection setup
├── models/
│   ├── disease_info_model.dart       # Model thông tin bệnh
│   └── disease_history_model.dart    # Model lịch sử
├── services/
│   ├── auth_service.dart             # Xác thực
│   ├── predict_service.dart          # Dự đoán bệnh
│   └── disease_history_service.dart  # Quản lý lịch sử
├── screens/
│   ├── auth/                         # Màn hình đăng nhập, đăng ký
│   ├── home/                         # Màn hình chính, camera
│   ├── predict/                      # Màn hình kết quả
│   └── history/                      # Màn hình lịch sử
├── widgets/
│   ├── app_notification.dart         # Custom notification system
│   ├── gradient_background.dart      # Background gradients
│   └── modern_loading_indicator.dart # Loading indicators
└── utils/
    └── toast_helper.dart             # Notification helper
```

## Yêu cầu hệ thống

- Flutter SDK: >= 3.7.0
- Dart SDK: >= 3.0.0
- Android: minSdkVersion 21 (Android 5.0)
- iOS: 11.0+

## Cài đặt và chạy

### 1. Clone repository

```bash
git clone <repository-url>
cd tomato-disease-detect
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Cấu hình API endpoint

Cập nhật URL API trong file `lib/constants/api_constant.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'http://your-api-url:8000';
}
```

### 4. Chạy ứng dụng

```bash
# Chạy trên emulator/device
flutter run

# Build APK cho Android
flutter build apk --release

# Build IPA cho iOS
flutter build ios --release
```

## API Backend

Ứng dụng kết nối với backend API FastAPI để:
- Xác thực người dùng
- Upload và phân tích ảnh
- Lưu và lấy lịch sử phân tích
- Lấy thông tin chi tiết về các loại bệnh

### Endpoint chính

- `POST /auth/login` - Đăng nhập
- `POST /auth/register` - Đăng ký
- `POST /predict/predict` - Phân tích ảnh (trả về ảnh có bounding box)
- `POST /predict/predict-disease` - Lấy thông tin bệnh
- `GET /history/{user_id}` - Lấy lịch sử
- `POST /history/save` - Lưu kết quả

## Phiên bản

**Current Version**: 2.0.0

### Changelog

**v2.0.0** (API v3.0)
- Chuyển về server-side bounding box drawing
- Thêm custom notification system (top overlay)
- Implement service locator pattern với GetIt
- Thêm gradient backgrounds cho UI
- Flexible image sizing theo aspect ratio
- Cải thiện animations và transitions

**v1.0.0**
- Release đầu tiên với tính năng cơ bản

## Tác giả

Phát triển như một phần của dự án nhận diện bệnh cây trồng.

## License

Private project - All rights reserved.
