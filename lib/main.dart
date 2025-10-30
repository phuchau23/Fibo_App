// main.dart
import 'package:flutter/material.dart' show ThemeMode, Scaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:swp_app/core/theme/shadcn_theme.dart';
import 'package:swp_app/features/profile/presentation/pages/change_password_page.dart';
import 'package:swp_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:swp_app/shared/presentation/footer-menu.dart';
import 'package:intl/date_symbol_data_local.dart';

// Pages
import 'package:swp_app/features/auth/presentation/pages/login_page.dart';
import 'package:swp_app/features/auth/presentation/pages/register_page.dart';
import 'package:swp_app/shared/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    // GoRoute(
    //   path: '/profile/edit',
    //   name: 'edit-profile',
    //   builder: (context, state) => const EditProfilePage(),
    // ),
    // // ...
    // GoRoute(
    //   path: '/profile/change-password',
    //   name: 'change-password',
    //   builder: (context, state) => const ChangePasswordPage(),
    // ),

    // ===== Shell có Footer dưới cùng =====
    ShellRoute(
      builder: (context, state, child) {
        final colors = ShadTheme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            // Lưu ý: nếu child tự là Scaffold thì vẫn hoạt động;
            // tốt nhất là tránh Scaffold lồng Scaffold trong các page con.
            child: child,
          ),
          bottomNavigationBar: const FooterMenu(),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        // Thêm các màn khác cần footer vào đây:
        // GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
  ],
);

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'fibo_app',
      themeMode: ThemeMode.light,
      theme: FiboShadcnTheme.lightTheme,
      darkTheme: FiboShadcnTheme.darkTheme,
      routerConfig: _router,
      // ShadToaster yêu cầu truyền child bắt buộc
      builder: (context, child) =>
          ShadToaster(child: child ?? const SizedBox.shrink()),
    );
  }
}
