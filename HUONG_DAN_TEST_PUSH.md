# 🧪 Hướng dẫn Test Push Notification

## 📱 Bước 1: Chuẩn bị App

### 1.1. Build và cài đặt APK
```bash
flutter build apk --release
```
Sau đó cài APK vào thiết bị Android.

### 1.2. Hoặc chạy trực tiếp
```bash
flutter run
```

## 🔑 Bước 2: Lấy FCM Device Token

### Cách 1: Từ Console Log (Khuyên dùng)
1. Mở app và **đăng nhập**
2. Sau khi đăng nhập thành công, dialog xin quyền notification sẽ xuất hiện
3. Chọn **"Cho phép"** để cấp quyền
4. Trong terminal/console, tìm dòng:
   ```
   I/flutter: FCM token: cyNdQ2_iS3mf6j_y-D_x_r:APA91bGuJZu8-...
   ```
5. **Copy toàn bộ token** (rất dài, khoảng 150+ ký tự)

### Cách 2: Kiểm tra trong App
- Token sẽ được lưu trong `fcmDeviceTokenProvider`
- Có thể thêm UI tạm thời để hiển thị token (xem code mẫu bên dưới)

## 🚀 Bước 3: Test với Postman

### 3.1. Setup Request

**Method:** `POST`  
**URL:** `https://fibo.io.vn/api/notifications/push`  
**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "title": "Test Notification",
  "body": "Đây là thông báo test từ FCM",
  "token": "PASTE_YOUR_TOKEN_HERE",
  "data": {
    "notificationId": "test-notification-id-123",
    "feedbackId": "optional-feedback-id-if-exists"
  }
}
```

### 3.2. Gửi Request
- Click nút **"Execute"** trong Postman
- Kiểm tra response (nên là `200 OK`)

## ✅ Bước 4: Test các Trường hợp

### Test Case 1: App đang mở (Foreground) ⚡
1. **Mở app** và đăng nhập
2. **Giữ app ở foreground** (không tắt)
3. Gửi push notification từ Postman
4. **Kết quả mong đợi:**
   - ✅ Bottom sheet hiển thị trong app với title và body
   - ✅ Có nút "Xem chi tiết" để điều hướng
   - ✅ Click "Xem chi tiết" sẽ mở màn hình Notifications

### Test Case 2: App ở Background 📱
1. Mở app và đăng nhập
2. **Nhấn nút Home** để đưa app về background (không đóng hoàn toàn)
3. Gửi push notification từ Postman
4. **Kết quả mong đợi:**
   - ✅ Notification xuất hiện ở **status bar** (phía trên màn hình)
   - ✅ Có title và body hiển thị
   - ✅ Khi **click vào notification**:
     - App sẽ mở lại
     - Tự động điều hướng đến màn hình **Notifications**
     - Nếu có `feedbackId`, sẽ mở detail sheet

### Test Case 3: App đã tắt hoàn toàn 🔒
1. **Đóng app hoàn toàn** (swipe away từ recent apps)
2. Gửi push notification từ Postman
3. **Kết quả mong đợi:**
   - ✅ Notification xuất hiện ở **status bar**
   - ✅ Khi **click vào notification**:
     - App sẽ **khởi động lại**
     - Tự động điều hướng đến màn hình **Notifications**
     - Xử lý navigation action nếu có

### Test Case 4: Test với Feedback ID 🔗
**Body JSON:**
```json
{
  "title": "Feedback cần xem xét",
  "body": "Sinh viên đánh giá AI chưa hữu ích",
  "token": "YOUR_TOKEN_HERE",
  "data": {
    "notificationId": "test-notification-id-123",
    "feedbackId": "REAL_FEEDBACK_ID_FROM_YOUR_DB"
  }
}
```

**Kết quả mong đợi:**
- ✅ Khi click vào notification, mở detail sheet
- ✅ Có nút **"Đi tới Feedback"**
- ✅ Click nút sẽ mở **Feedback detail sheet**

## 🛠️ Troubleshooting

### ❌ Không nhận được notification:
1. **Kiểm tra token:**
   - Token phải đúng và đầy đủ (150+ ký tự)
   - Token có thể thay đổi khi cài lại app

2. **Kiểm tra quyền:**
   - Vào **Settings > Apps > Fibo Mentor > Notifications**
   - Đảm bảo notifications đã được bật

3. **Kiểm tra Firebase:**
   - Xác nhận `google-services.json` đã được thêm vào `android/app/`
   - Kiểm tra Firebase Console > Cloud Messaging

4. **Kiểm tra console log:**
   - Tìm lỗi trong terminal khi chạy `flutter run`
   - Kiểm tra `FCM permission status` trong log

### ❌ Notification không điều hướng:
1. **Kiểm tra `data` payload:**
   - Phải có `notificationId` hoặc `id`
   - `feedbackId` là optional

2. **Kiểm tra app state:**
   - App phải đã được khởi động ít nhất 1 lần
   - FCM service phải đã được initialize

## 📝 Ví dụ Request Body đầy đủ

```json
{
  "title": "Thông báo mới",
  "body": "Bạn có feedback mới cần xem xét",
  "token": "cyNdQ2_iS3mf6j_y-D_x_r:APA91bGuJZu8-_F7uZ3K4O2I2dy7E5WfE8tV5ETXOCLSp6d7JTy_6q86du1W16ruZ6kqpKWLUjYUOZNQVoS_0ypKtlhlxXs6C8YtDV7ECwessODQWv9Mrsc",
  "data": {
    "notificationId": "019a38d4-0dfc-7321-8e7b-090eb23fe337",
    "feedbackId": "fa7655a9-f1ee-462b-b6cf-979f8019acb1"
  }
}
```

## 🎯 Checklist Test

- [ ] App đã được cài đặt và đăng nhập thành công
- [ ] Đã cấp quyền notification (dialog xuất hiện sau login)
- [ ] Đã lấy được FCM token từ console
- [ ] Đã gửi request từ Postman với token đúng
- [ ] Test foreground: Bottom sheet hiển thị ✅
- [ ] Test background: Notification ở status bar ✅
- [ ] Test closed: App khởi động khi click notification ✅
- [ ] Test với feedbackId: Điều hướng đúng ✅

## 💡 Tips

1. **Token thay đổi khi:**
   - Cài đặt lại app
   - Xóa dữ liệu app
   - Cập nhật app
   - Token được refresh tự động

2. **Test nhanh:**
   - Dùng Postman Collection để lưu request
   - Tạo environment variable cho token để dễ thay đổi

3. **Debug:**
   - Bật verbose logging: `flutter run -v`
   - Kiểm tra Firebase Console > Cloud Messaging > Reports

