# Script để reset notification permission cho app
# Sử dụng: .\reset_notification_permission.ps1

$adbPath = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"

if (Test-Path $adbPath) {
    Write-Host "Đang revoke notification permission..." -ForegroundColor Yellow
    & $adbPath shell pm revoke com.example.swp_app android.permission.POST_NOTIFICATIONS
    Write-Host "✅ Đã revoke permission thành công!" -ForegroundColor Green
    Write-Host "Bây giờ bạn có thể chạy 'flutter run' để test lại dialog xin quyền." -ForegroundColor Cyan
} else {
    Write-Host "❌ Không tìm thấy ADB tại: $adbPath" -ForegroundColor Red
    Write-Host "Vui lòng kiểm tra đường dẫn Android SDK của bạn." -ForegroundColor Yellow
}

