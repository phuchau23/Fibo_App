// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:swp_app/core/services/fcm_service.dart';
import 'package:swp_app/core/theme/shadcn_theme.dart';
import 'package:swp_app/firebase_options.dart';
import 'package:swp_app/shared/presentation/footer-menu.dart';
import 'package:swp_app/shared/presentation/pages/home_page.dart';
import 'package:swp_app/features/auth/presentation/pages/login_page.dart';
import 'package:swp_app/features/auth/presentation/pages/register_page.dart';
import 'package:swp_app/features/notification/presentation/models/notification_navigation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Log để debug (chỉ khi app đã tắt hoàn toàn)
  debugPrint('📱 [BACKGROUND] Received notification when app is terminated:');
  debugPrint(
    '   Title: ${message.notification?.title ?? message.data['title']}',
  );
  debugPrint('   Body: ${message.notification?.body ?? message.data['body']}');
  debugPrint('   Data: ${message.data}');

  // Note: Khi app đã tắt, Firebase sẽ tự động hiển thị notification ở status bar
  // nếu payload có 'notification' object (title, body).
  // Logic xử lý navigation sẽ được thực hiện khi user click vào notification
  // thông qua getInitialMessage() trong initialize().
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await initializeDateFormatting('vi_VN', null);
  runApp(const ProviderScope(child: AppRoot()));
}

/// Router sử dụng ShellRoute để bọc các trang cần footer
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    // ===== Public routes (không có footer) =====
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),

    // ===== Shell có Footer dưới cùng =====
    ShellRoute(
      builder: (context, state, child) {
        final colors = ShadTheme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(child: child),
          bottomNavigationBar: const FooterMenu(),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    ),
  ],
);

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  bool _showingNotification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcmServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to in-app notifications
    ref.listen<InAppNotificationPayload?>(inAppNotificationProvider, (
      previous,
      next,
    ) {
      if (next != null && !_showingNotification) {
        _showingNotification = true;
        Future.microtask(() async {
          await _showInAppNotification(next);
          _showingNotification = false;
          ref.read(inAppNotificationProvider.notifier).state = null;
        });
      }
    });

    return ShadApp.router(
      title: 'fibo_app',
      themeMode: ThemeMode.light,
      theme: FiboShadcnTheme.lightTheme,
      darkTheme: FiboShadcnTheme.darkTheme,
      routerConfig: _router,
      builder: (context, child) =>
          ShadToaster(child: child ?? const SizedBox.shrink()),
    );
  }

  Future<void> _showInAppNotification(InAppNotificationPayload payload) async {
    if (!mounted) return;
    final shouldNavigate =
        await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_outlined,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              payload.title,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        payload.body,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: const Color(0xFF475467),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Đóng'),
                          ),
                          const Spacer(),
                          if (payload.action != null)
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Xem chi tiết'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;

    if (shouldNavigate && payload.action != null) {
      ref.read(fcmServiceProvider).handleForegroundTap(payload.action!);
    }
  }
}
