# 🔍 Kiểm tra Push Notification khi App đã tắt

## ⚠️ Quan trọng: Format Payload

Để notification hiển thị ở **status bar** khi app đã tắt hoàn toàn, payload **PHẢI** có cả `notification` object và `data` object:

### ✅ Payload ĐÚNG (hiển thị ở status bar):

```json
{
  "title": "Test Notification",
  "body": "Đây là thông báo test từ FCM",
  "token": "YOUR_DEVICE_TOKEN",
  "data": {
    "notificationId": "test-notification-id-123",
    "feedbackId": "optional-feedback-id"
  }
}
```

**Lưu ý:** Backend của bạn phải gửi payload với cả `notification` và `data`:

- `notification.title` và `notification.body` → Để hiển thị ở status bar
- `data` → Để xử lý navigation khi click vào notification

### ❌ Payload SAI (không hiển thị khi app tắt):

```json
{
  "token": "YOUR_TOKEN",
  "data": {
    "title": "Test",
    "body": "Test body",
    "notificationId": "123"
  }
}
```

**Vấn đề:** Chỉ có `data`, không có `notification` object → Android sẽ không tự động hiển thị notification khi app đã tắt.

## 🧪 Cách Test App đã tắt hoàn toàn

### Bước 1: Đảm bảo App đã được cài và có permission

1. Cài app: `flutter install` hoặc cài APK
2. Mở app và cấp quyền notification
3. Lấy FCM token từ console log

### Bước 2: Đóng app hoàn toàn

1. Mở Recent Apps (swipe up từ bottom)
2. **Swipe away** app để đóng hoàn toàn
3. Hoặc dùng lệnh:
   ```bash
   adb shell am force-stop com.example.swp_app
   ```

### Bước 3: Gửi Push Notification

**POST** `https://fibo.io.vn/api/notifications/push`

**Body:**

```json
{
  "title": "Test khi app tắt",
  "body": "Notification này sẽ hiển thị ở status bar",
  "token": "YOUR_DEVICE_TOKEN",
  "data": {
    "notificationId": "test-123",
    "feedbackId": "optional-feedback-id"
  }
}
```

### Bước 4: Kiểm tra kết quả

1. **Notification phải xuất hiện ở status bar** (phía trên màn hình)
2. **Click vào notification:**
   - App sẽ khởi động lại
   - Tự động điều hướng đến màn hình Notifications
   - Nếu có `feedbackId`, sẽ mở detail sheet

## 🔍 Debug khi không thấy notification

### 1. Kiểm tra Logcat (khi app đã tắt):

```bash
adb logcat | grep -i "firebase\|fcm\|notification"
```

Tìm dòng:

```
📱 [BACKGROUND] Received notification when app is terminated:
```

### 2. Kiểm tra Permission:

```bash
adb shell dumpsys package com.example.swp_app | grep notification
```

Hoặc vào: Settings > Apps > Fibo Mentor > Notifications

### 3. Kiểm tra Payload từ Server:

- Đảm bảo response có `statusCode: 200`
- Kiểm tra `responseId` có được trả về không
- Xác nhận backend đã gửi cả `notification` và `data`

### 4. Test với Firebase Console:

1. Vào Firebase Console > Cloud Messaging
2. Click "Send test message"
3. Nhập FCM token
4. Nhập title và body
5. Thêm custom data:
   ```json
   {
     "notificationId": "test-123",
     "feedbackId": "optional-id"
   }
   ```
6. Gửi và kiểm tra

## 📋 Checklist Test

- [ ] App đã được cài đặt
- [ ] Permission notification đã được cấp
- [ ] FCM token đã được lấy
- [ ] App đã được đóng hoàn toàn (force-stop)
- [ ] Payload có cả `notification` và `data`
- [ ] Gửi request từ Postman/Backend
- [ ] Notification xuất hiện ở status bar ✅
- [ ] Click notification → App khởi động ✅
- [ ] Click notification → Điều hướng đúng ✅

## 🐛 Troubleshooting

### Không thấy notification ở status bar:

1. **Kiểm tra payload:**

   - Phải có `notification.title` và `notification.body`
   - Backend phải gửi đúng format FCM

2. **Kiểm tra permission:**

   - Settings > Apps > Fibo Mentor > Notifications = ON

3. **Kiểm tra Do Not Disturb:**

   - Tắt Do Not Disturb mode
   - Kiểm tra notification settings của thiết bị

4. **Kiểm tra token:**
   - Token có thể đã thay đổi
   - Lấy token mới và test lại

### App không khởi động khi click notification:

1. **Kiểm tra `getInitialMessage()`:**

   - Phải được gọi trong `initialize()`
   - Đã có logic xử lý navigation

2. **Kiểm tra log:**
   - Tìm log `getInitialMessage` trong console
   - Kiểm tra `pendingNotificationActionProvider` có được set không

## 💡 Lưu ý quan trọng

1. **Payload format:**

   - `notification` object → Hiển thị ở status bar
   - `data` object → Xử lý logic trong app

2. **Background handler:**

   - Chỉ chạy khi app đã tắt hoàn toàn
   - Không thể truy cập Riverpod providers
   - Chỉ có thể log hoặc lưu vào local storage

3. **Navigation khi app tắt:**
   - Sử dụng `getInitialMessage()` khi app khởi động
   - Lưu navigation action vào `pendingNotificationActionProvider`
   - Xử lý trong `NotificationListPage`
