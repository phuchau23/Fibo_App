# 🔍 Xác định khi nào App "đóng"

## 📱 Các trạng thái của App

### 1. **App đang mở (Foreground)**

- App đang hiển thị trên màn hình
- User đang tương tác với app
- **Notification behavior:**
  - FCM `onMessage` được gọi
  - Notification **KHÔNG** hiển thị ở status bar
  - Hiển thị in-app notification (bottom sheet) thay thế

### 2. **App ở background**

- User nhấn Home button
- User chuyển sang app khác
- App vẫn chạy trong bộ nhớ nhưng không hiển thị
- **Notification behavior:**
  - Notification **HIỂN THỊ** ở status bar
  - Khi user click notification → `onMessageOpenedApp` được gọi
  - App được đưa lên foreground

### 3. **App đã tắt hoàn toàn (Terminated)**

- User swipe away app từ Recent Apps
- Hoặc app bị kill bởi hệ thống
- App không còn chạy trong bộ nhớ
- **Notification behavior:**
  - Notification **HIỂN THỊ** ở status bar
  - Khi user click notification → App khởi động lại
  - `getInitialMessage()` được gọi trong `initialize()`
  - App điều hướng đến màn hình phù hợp

## 🔄 Luồng xử lý Notification

### Khi App đang mở (Foreground):

```
Backend gửi FCM push
  → Firebase Messaging nhận được
  → onMessage listener được trigger
  → _handleForegroundMessage()
  → Hiển thị in-app notification (bottom sheet)
  → User có thể click để điều hướng
```

### Khi App ở background:

```
Backend gửi FCM push
  → Firebase Messaging nhận được
  → Android/iOS hiển thị notification ở status bar
  → User click notification
  → onMessageOpenedApp listener được trigger
  → _handleMessageOpenedApp()
  → App được đưa lên foreground
  → Điều hướng đến màn hình phù hợp
```

### Khi App đã tắt hoàn toàn:

```
Backend gửi FCM push
  → Firebase Messaging nhận được
  → Android/iOS hiển thị notification ở status bar
  → User click notification
  → App khởi động lại
  → main() được gọi
  → Firebase.initializeApp()
  → AppRoot được build
  → FcmService.initialize()
  → getInitialMessage() được gọi
  → Nếu có initial message → _handleMessageOpenedApp()
  → Điều hướng đến màn hình phù hợp
```

## 🧪 Cách Test các trạng thái

### Test 1: App đang mở (Foreground)

1. **Mở app và để app hiển thị trên màn hình**
2. **Gửi push notification từ backend**
3. **Kết quả mong đợi:**
   - ✅ In-app notification (bottom sheet) xuất hiện
   - ❌ Notification **KHÔNG** xuất hiện ở status bar
   - ✅ Log: `onMessage` được gọi

### Test 2: App ở background

1. **Mở app**
2. **Nhấn Home button** (đưa app về background)
3. **Gửi push notification từ backend**
4. **Kết quả mong đợi:**
   - ✅ Notification **HIỂN THỊ** ở status bar
   - ✅ Click notification → App được đưa lên foreground
   - ✅ Log: `onMessageOpenedApp` được gọi

### Test 3: App đã tắt hoàn toàn

1. **Mở app**
2. **Đóng app hoàn toàn:**
   ```bash
   adb shell am force-stop com.example.swp_app
   ```
   Hoặc swipe away app từ Recent Apps
3. **Gửi push notification từ backend**
4. **Kết quả mong đợi:**
   - ✅ Notification **HIỂN THỊ** ở status bar
   - ✅ Click notification → App khởi động lại
   - ✅ Log: `getInitialMessage` được gọi
   - ✅ App điều hướng đến màn hình phù hợp

## 🔍 Cách xác định trạng thái trong code

### Trong Flutter:

```dart
import 'dart:async';
import 'package:flutter/widgets.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App đang mở (foreground)
        debugPrint('App resumed (foreground)');
        break;
      case AppLifecycleState.inactive:
        // App đang chuyển trạng thái (tạm thời)
        debugPrint('App inactive');
        break;
      case AppLifecycleState.paused:
        // App ở background
        debugPrint('App paused (background)');
        break;
      case AppLifecycleState.detached:
        // App sắp bị đóng
        debugPrint('App detached');
        break;
      case AppLifecycleState.hidden:
        // App bị ẩn (Android 14+)
        debugPrint('App hidden');
        break;
    }
  }
}
```

### Sử dụng trong App:

```dart
class _AppRootState extends ConsumerState<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      debugPrint('App moved to background');
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed to foreground');
    }
  }
}
```

## 📋 Checklist xác định App đóng

- [ ] **App ở background:**

  - User nhấn Home button
  - `AppLifecycleState.paused` được trigger
  - Notification hiển thị ở status bar

- [ ] **App đã tắt hoàn toàn:**
  - User swipe away app
  - Hoặc `adb shell am force-stop`
  - App không còn trong Recent Apps
  - Notification hiển thị ở status bar
  - Click notification → App khởi động lại

## ⚠️ Lưu ý

1. **Background vs Terminated:**

   - **Background**: App vẫn chạy trong bộ nhớ → `onMessageOpenedApp` được gọi
   - **Terminated**: App không còn chạy → `getInitialMessage()` được gọi khi app khởi động lại

2. **Notification hiển thị:**

   - Chỉ hiển thị ở status bar khi app **KHÔNG** ở foreground
   - Khi app ở foreground → Hiển thị in-app notification thay thế

3. **Payload format:**
   - Để notification hiển thị ở status bar, payload **PHẢI** có `notification` object (title, body)
   - Nếu chỉ có `data` → Notification không hiển thị khi app đóng

## ✅ Kết luận

App được coi là **"đóng"** khi:

- ✅ App ở background (`AppLifecycleState.paused`)
- ✅ App đã tắt hoàn toàn (không còn trong bộ nhớ)

Trong cả 2 trường hợp, notification sẽ hiển thị ở status bar và user có thể click để mở app.
