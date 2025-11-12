# Hướng dẫn Test Push Notification

## Bước 1: Lấy FCM Device Token

### Cách 1: Từ Console Log
1. Chạy app: `flutter run`
2. Đăng nhập vào app
3. Trong terminal, tìm dòng log:
   ```
   I/flutter: FCM token: YOUR_DEVICE_TOKEN_HERE
   ```
4. Copy token này

### Cách 2: Từ Code (Tạm thời để test)
Thêm code tạm thời vào `NotificationListPage` để hiển thị token trên màn hình (xem phần dưới)

## Bước 2: Gọi API Push Notification

### Sử dụng Postman:

**Method:** `POST`  
**URL:** `https://fibo.io.vn/api/notifications/push`  
**Headers:**
```
Content-Type: application/json
Authorization: Bearer YOUR_JWT_TOKEN (nếu cần)
```

**Body (JSON):**
```json
{
  "title": "Test Notification",
  "body": "Đây là thông báo test từ FCM",
  "token": "YOUR_DEVICE_TOKEN_HERE",
  "data": {
    "notificationId": "test-notification-id-123",
    "feedbackId": "optional-feedback-id-if-exists"
  }
}
```

### Sử dụng cURL:
```bash
curl -X POST https://fibo.io.vn/api/notifications/push \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Test Notification",
    "body": "Đây là thông báo test từ FCM",
    "token": "YOUR_DEVICE_TOKEN_HERE",
    "data": {
      "notificationId": "test-notification-id-123",
      "feedbackId": "optional-feedback-id-if-exists"
    }
  }'
```

## Bước 3: Test các trường hợp

### 3.1. App đang chạy (Foreground)
1. Mở app và đăng nhập
2. Gọi API push notification
3. **Kết quả mong đợi:**
   - Bottom sheet hiển thị trong app với title và body
   - Có nút "Xem chi tiết" để điều hướng

### 3.2. App ở background
1. Mở app và đăng nhập
2. Nhấn nút Home để đưa app về background
3. Gọi API push notification
4. **Kết quả mong đợi:**
   - Notification xuất hiện ở status bar
   - Khi click vào notification, app sẽ mở và điều hướng đến màn hình Notifications

### 3.3. App đã tắt hoàn toàn
1. Đóng app hoàn toàn (swipe away)
2. Gọi API push notification
3. **Kết quả mong đợi:**
   - Notification xuất hiện ở status bar
   - Khi click vào notification, app sẽ khởi động và điều hướng đến màn hình Notifications

## Bước 4: Test với Feedback ID

Để test điều hướng đến Feedback detail:

```json
{
  "title": "Feedback cần xem xét",
  "body": "Sinh viên đánh giá AI chưa hữu ích",
  "token": "YOUR_DEVICE_TOKEN_HERE",
  "data": {
    "notificationId": "test-notification-id-123",
    "feedbackId": "REAL_FEEDBACK_ID_FROM_YOUR_DB"
  }
}
```

**Kết quả mong đợi:**
- Khi click vào notification, app sẽ mở detail sheet của notification
- Có nút "Đi tới Feedback"
- Click vào nút sẽ mở Feedback detail sheet

## Lưu ý quan trọng:

1. **Token thay đổi:** FCM token có thể thay đổi khi:
   - Cài đặt lại app
   - Xóa dữ liệu app
   - Cập nhật app
   - Token được refresh tự động

2. **Permission:** Đảm bảo app đã được cấp quyền notification trên thiết bị

3. **Firebase Console:** Có thể test trực tiếp từ Firebase Console:
   - Vào Firebase Console > Cloud Messaging
   - Chọn "Send test message"
   - Nhập FCM token và gửi

## Troubleshooting:

- **Không nhận được notification:**
  - Kiểm tra token có đúng không
  - Kiểm tra app có quyền notification không
  - Kiểm tra Firebase configuration (google-services.json)
  - Kiểm tra console log để xem có lỗi gì không

- **Notification không điều hướng:**
  - Kiểm tra `data` payload có đúng format không
  - Kiểm tra `notificationId` và `feedbackId` có tồn tại trong database không

