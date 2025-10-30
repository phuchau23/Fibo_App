import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:swp_app/features/auth/data/models/auth_payloads.dart';

import '../blocs/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _email = ShadTextEditingController();
  final _password = ShadTextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    // ✅ Sửa regex: bỏ \ trước $
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    return ok ? null : 'Enter a valid email';
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    final notifier = ref.read(authControllerProvider.notifier);

    final emailError = _validateEmail(_email.text);
    final passError = _validatePassword(_password.text);

    if (emailError != null || passError != null) {
      ShadToaster.of(context).show(
        const ShadToast(title: Text('Please fix the highlighted fields.')),
      );
      setState(() {}); // để rebuild và hiển thị error
      return;
    }

    await notifier.login(
      LoginRequest(email: _email.text.trim(), password: _password.text),
    );

    ref
        .read(authControllerProvider)
        .when(
          data: (_) => context.go('/home'),
          loading: () {},
          error: (err, _) {
            ShadToaster.of(
              context,
            ).show(ShadToast.destructive(title: Text(err.toString())));
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✅ errorText & hint/label nằm trong InputDecoration (không dùng const)
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
            errorText: _validateEmail(_email.text),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: _obscure,
          onChanged: (_) => setState(() {}),
          // ✅ suffixIcon & errorText cũng đặt trong decoration
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '••••••••',
            errorText: _validatePassword(_password.text),
            suffixIcon: IconButton(
              icon: _obscure
                  ? const Icon(Icons.remove_red_eye)
                  : const Icon(Icons.remove_red_eye_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(value: true, onChanged: (_) {}),
            const SizedBox(width: 8),
            const Expanded(child: Text('Remember me')),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign in'),
        ),
        const SizedBox(height: 8),
        // ✅ Dùng ElevatedButton.icon thay vì leadingIcon
        ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () {
                  ShadToaster.of(context).show(
                    const ShadToast(title: Text('Continue with Google (stub)')),
                  );
                },
          // icon: const Icon(Icons.google),
          label: const Text('Continue with Google'),
        ),
      ],
    );
  }
}
