import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/profile/presentation/blocs/profile_providers.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    oldCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Get the current context at the start of the method
    final currentContext = context;

    if (newCtrl.text != confirmCtrl.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Xác nhận mật khẩu không khớp')),
      );
      return;
    }

    try {
      await ref
          .read(changePasswordControllerProvider.notifier)
          .submit(
            oldPassword: oldCtrl.text,
            newPassword: newCtrl.text,
            confirmNewPassword: confirmCtrl.text,
          );

      if (!mounted) return;
      final st = ref.read(changePasswordControllerProvider);

      if (st.hasError) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          currentContext,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${st.error}')));
      } else {
        if (!mounted) return;
        // Show success message
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật mật khẩu thành công'),
            duration: Duration(seconds: 2),
          ),
        );
        // Wait for the snackbar to show before navigating back
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        // Pop to root and then to profile
        Navigator.of(currentContext).popUntil((route) => route.isFirst);
        Navigator.of(currentContext).pushReplacementNamed('/profile');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        currentContext,
      ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(changePasswordControllerProvider).isLoading;
    const bg = Color(0xFFF9FAFB);

    // Build password field with visibility toggle
    Widget _buildPasswordField({
      required TextEditingController controller,
      required String labelText,
      required bool isVisible,
      required VoidCallback onToggle,
      String? Function(String?)? validator,
    }) {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
        ),
        obscureText: !isVisible,
        validator: validator,
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            decoration: _cardDecoration,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPasswordField(
                    controller: oldCtrl,
                    labelText: 'Mật khẩu cũ',
                    isVisible: _isOldPasswordVisible,
                    onToggle: () => setState(
                      () => _isOldPasswordVisible = !_isOldPasswordVisible,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: newCtrl,
                    labelText: 'Mật khẩu mới',
                    isVisible: _isNewPasswordVisible,
                    onToggle: () => setState(
                      () => _isNewPasswordVisible = !_isNewPasswordVisible,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: confirmCtrl,
                    labelText: 'Xác nhận mật khẩu mới',
                    isVisible: _isConfirmPasswordVisible,
                    onToggle: () => setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Bắt buộc';
                      if (v != newCtrl.text) return 'Mật khẩu không khớp';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : _submit,
            child: loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black12.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
