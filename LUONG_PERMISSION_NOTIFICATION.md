# 🔔 Luồng Permission Notification

## 📋 Tóm tắt

App sẽ **tự động hỏi permission notification** ngay khi mở app lần đầu, không cần đăng nhập.

## 🔄 Luồng hoạt động

### 1. Khi App khởi động lần đầu

```
main()
  → Firebase.initializeApp()
  → runApp(AppRoot)
    → AppRoot.initState()
      → _initializeFCM() (sau 100ms)
        → FcmService.initialize()
          → _requestPermission()
            → Kiểm tra permission status hiện tại
            → Nếu chưa có → Hiển thị dialog "Cho phép Fibo Mentor gửi thông báo?"
            → Nếu đã có → Skip
          → _syncToken() (lấy FCM token)
```

### 2. Permission Status

- **`notDetermined`**: Chưa hỏi bao giờ → Sẽ hiển thị dialog
- **`authorized`**: Đã cho phép → Không hiển thị dialog nữa
- **`denied`**: Đã từ chối → Không hiển thị dialog (user phải vào Settings)
- **`provisional`**: Tạm thời cho phép (iOS) → Không hiển thị dialog

### 3. Khi nào App được coi là "đóng"?

App được coi là **đóng** khi:

1. **App đã tắt hoàn toàn:**

   - User swipe away app từ Recent Apps
   - Hoặc dùng lệnh: `adb shell am force-stop com.example.swp_app`
   - → Notification sẽ hiển thị ở **status bar**
   - → Khi click notification, app khởi động lại và `getInitialMessage()` được gọi

2. **App ở background:**

   - User nhấn Home button
   - Hoặc chuyển sang app khác
   - → Notification sẽ hiển thị ở **status bar**
   - → Khi click notification, `onMessageOpenedApp` được gọi

3. **App đang mở (foreground):**
   - App đang hiển thị trên màn hình
   - → Notification **KHÔNG** hiển thị ở status bar
   - → `onMessage` được gọi → Hiển thị in-app notification (bottom sheet)

## 🧪 Cách Test Permission

### Test 1: Permission lần đầu

1. **Xóa app hoàn toàn:**

   ```bash
   adb uninstall com.example.swp_app
   ```

2. **Cài lại app:**

   ```bash
   flutter install
   # hoặc
   flutter run
   ```

3. **Mở app:**
   - Dialog permission **PHẢI** xuất hiện ngay khi app mở
   - Không cần đăng nhập

### Test 2: Permission đã được cấp

1. **Mở app:**
   - Dialog permission **KHÔNG** xuất hiện
   - Log sẽ hiển thị: `✅ FCM permission already granted, skipping request`

### Test 3: Permission đã bị từ chối

1. **Từ chối permission:**

   - Vào Settings > Apps > Fibo Mentor > Notifications > OFF

2. **Mở app:**
   - Dialog permission **KHÔNG** xuất hiện
   - Log sẽ hiển thị: `❌ FCM permission denied`
   - User phải vào Settings để bật lại

### Test 4: Reset Permission (để test lại)

**Windows PowerShell:**

```powershell
.\reset_notification_permission.ps1
```

**Hoặc thủ công:**

```bash
adb shell pm revoke com.example.swp_app android.permission.POST_NOTIFICATIONS
```

Sau đó mở lại app → Dialog sẽ xuất hiện lại.

## 📱 Log Debug

Khi mở app, kiểm tra log để xem permission status:

```
FCM current permission status: AuthorizationStatus.notDetermined
📱 Requesting FCM permission...
FCM permission request result: AuthorizationStatus.authorized
✅ FCM permission granted
FCM token: [TOKEN_HERE]
✅ FCM initialized successfully
```

## ⚠️ Lưu ý quan trọng

1. **Permission chỉ hỏi 1 lần:**

   - Nếu user đã cho phép → Không hỏi lại
   - Nếu user đã từ chối → Phải vào Settings để bật lại

2. **Android 13+ (API 33+):**

   - Cần permission `POST_NOTIFICATIONS` (đã có trong AndroidManifest.xml)
   - Permission dialog được hệ thống Android hiển thị, không phải Flutter

3. **iOS:**

   - Permission dialog được hệ thống iOS hiển thị
   - Có thể có `provisional` status (tạm thời cho phép)

4. **Timing:**
   - Permission được request sau 100ms khi app khởi động
   - Đảm bảo widget tree đã sẵn sàng nhưng không đợi quá lâu

## 🐛 Troubleshooting

### Không thấy dialog permission:

1. **Kiểm tra permission đã được cấp chưa:**

   ```bash
   adb shell dumpsys package com.example.swp_app | grep notification
   ```

2. **Reset permission:**

   ```bash
   adb shell pm revoke com.example.swp_app android.permission.POST_NOTIFICATIONS
   ```

3. **Kiểm tra log:**

   - Tìm `FCM current permission status` trong log
   - Nếu là `authorized` → Đã được cấp rồi, không hiển thị dialog

4. **Kiểm tra Android version:**
   - Android 13+ mới có permission `POST_NOTIFICATIONS`
   - Android < 13: Permission được cấp tự động khi cài app

### Dialog xuất hiện quá muộn:

- Hiện tại delay 100ms để đảm bảo widget tree sẵn sàng
- Nếu cần nhanh hơn, có thể giảm xuống 50ms
- Nhưng không nên bỏ delay hoàn toàn vì có thể gây lỗi

## ✅ Checklist

- [x] Permission được request ngay khi app khởi động
- [x] Không cần đăng nhập để request permission
- [x] Kiểm tra permission status trước khi request
- [x] Log chi tiết để debug
- [x] Xử lý các trường hợp: granted, denied, notDetermined
- [x] Đảm bảo timing đúng (100ms delay)
