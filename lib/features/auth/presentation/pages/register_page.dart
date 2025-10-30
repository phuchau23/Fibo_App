import 'package:flutter/material.dart' show ThemeMode, TextInputAction, Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:swp_app/features/auth/data/models/auth_payloads.dart';
import 'package:swp_app/features/auth/presentation/blocs/auth_provider.dart';
import 'package:swp_app/features/auth/presentation/widgets/password_input.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.length < 6) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Điền đủ họ tên, email và mật khẩu (≥ 6 ký tự)'),
        ),
      );
      return;
    }

    final body = RegisterRequest(
      email: _email.text.trim(),
      password: _password.text,
      name: _name.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    );

    final ctrl = ref.read(authControllerProvider.notifier);
    final either = await ctrl.register(body);

    either.fold(
      (err) => ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Đăng ký thất bại'),
          description: Text(err),
        ),
      ),
      (_) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Đăng ký thành công'),
            description: Text('Bạn có thể đăng nhập ngay bây giờ'),
          ),
        );
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(authControllerProvider);
    final colors = ShadTheme.of(context).colorScheme;

    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ShadCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo tài khoản ✨',
                          style: ShadTheme.of(
                            context,
                          ).textTheme.h4.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chỉ mất một phút để bắt đầu',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Họ và tên'),
                  ),
                  ShadInput(
                    controller: _name,
                    placeholder: const Text('Nguyễn Văn A'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email'),
                  ),
                  ShadInput(
                    controller: _email,
                    placeholder: const Text('you@example.com'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Số điện thoại (tuỳ chọn)'),
                  ),
                  ShadInput(
                    controller: _phone,
                    placeholder: const Text('0123 456 789'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Mật khẩu'),
                  ),
                  PasswordInput(controller: _password),

                  const SizedBox(height: 16),

                  ShadButton(
                    width: double.infinity,
                    onPressed: async.isLoading ? null : _submit,
                    child: async.isLoading
                        ? const ShadProgress(
                            minHeight: 16,
                            color: Colors.orange,
                          )
                        : const Text('Đăng ký'),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản?',
                        style: ShadTheme.of(context).textTheme.muted,
                      ),
                      ShadButton.link(
                        onPressed: () => context.go('/login'),
                        child: const Text('Đăng nhập'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
