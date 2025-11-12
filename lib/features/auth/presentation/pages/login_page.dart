import 'package:flutter/material.dart' show ThemeMode, Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:swp_app/features/auth/data/models/auth_payloads.dart';
import 'package:swp_app/features/auth/presentation/blocs/auth_provider.dart';
import 'package:swp_app/features/auth/presentation/widgets/email_input.dart';
import 'package:swp_app/features/auth/presentation/widgets/password_input.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_email.text.trim().isEmpty || _password.text.length < 6) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Vui lòng nhập email và mật khẩu (≥ 6 ký tự)'),
        ),
      );
      return;
    }

    final ctrl = ref.read(authControllerProvider.notifier);
    final either = await ctrl.login(
      LoginRequest(email: _email.text.trim(), password: _password.text),
    );

    either.fold(
      (err) => ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Đăng nhập thất bại'),
          description: Text(err),
        ),
      ),
      (_) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('Đăng nhập thành công')));
        context.go('/');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(authControllerProvider);

    return ColoredBox(
      // nền cam nhạt như mock
      color: ShadTheme.of(context).colorScheme.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ảnh hero phía trên (đổi link/asset nếu muốn)
                    Center(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        height: 160,
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // EMAIL
                          _FieldLabel('Email address'),
                          EmailInput(controller: _email),
                          const SizedBox(height: 12),

                          // PASSWORD
                          _FieldLabel('Password'),
                          PasswordInput(controller: _password),
                          const SizedBox(height: 8),

                          // Remember + Forget
                          Row(
                            children: [
                              ShadCheckbox(
                                value: _remember,
                                onChanged: (v) => setState(() => _remember = v),
                              ),
                              const SizedBox(width: 8),
                              const Text('Remember me'),
                              const Spacer(),
                              ShadButton.link(
                                onPressed: () => ShadToaster.of(context).show(
                                  const ShadToast(
                                    title: Text(
                                      'Tính năng quên mật khẩu đang phát triển',
                                    ),
                                  ),
                                ),
                                child: const Text('Forget password'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Continue
                          Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: ShadButton.ghost(
                              width: double.infinity,
                              height: 54,
                              padding: EdgeInsets
                                  .zero, // để chiếm full và không lộ viền/padding
                              onPressed: async.isLoading ? null : _submit,
                              child: async.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: ShadProgress(minHeight: 16),
                                    )
                                  : const Text(
                                      'Continue',
                                      style: TextStyle(
                                        color: Colors
                                            .white, // chữ trắng trên nền cam
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // divider "Or sign up with"
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Label nhỏ trên mỗi input để giống mock
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: ShadTheme.of(
          context,
        ).textTheme.small.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
