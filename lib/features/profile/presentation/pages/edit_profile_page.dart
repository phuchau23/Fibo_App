import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/profile/presentation/blocs/profile_providers.dart';
import 'package:swp_app/features/profile/domain/entities/user_profile.dart';

// Colors
const _bg = Color(0xFFF6F7F9);
const _textPrimary = Color(0xFF111827);
const _textSecondary = Color(0xFF6B7280);
const _accent = Color(0xFFFF8C42);
const _danger = Color(0xFFE11D48);
const _cardRadius = 16.0;

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController firstCtrl;
  late final TextEditingController lastCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController dobCtrl;
  late final TextEditingController sexCtrl;
  late final TextEditingController addressCtrl;
  Uri? avatarFileUri; // TODO: add picker if needed

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final UserProfile? p = ref.read(profileNotifierProvider).valueOrNull;
    firstCtrl = TextEditingController(text: p?.firstname ?? '');
    lastCtrl = TextEditingController(text: p?.lastname ?? '');
    phoneCtrl = TextEditingController(text: p?.phoneNumber ?? '');
    dobCtrl = TextEditingController(text: p?.dateOfBirth ?? '');
    sexCtrl = TextEditingController(text: p?.sex ?? '');
    addressCtrl = TextEditingController(text: p?.address ?? '');
  }

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    phoneCtrl.dispose();
    dobCtrl.dispose();
    sexCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_accent),
        ),
      ),
    );
    
    try {
      final ok = await ref
          .read(updateProfileControllerProvider.notifier)
          .submit(
            firstname: firstCtrl.text.trim(),
            lastname: lastCtrl.text.trim(),
            phoneNumber: phoneCtrl.text.trim().isEmpty
                ? null
                : phoneCtrl.text.trim(),
            dateOfBirth: dobCtrl.text.trim().isEmpty ? null : dobCtrl.text.trim(),
            sex: sexCtrl.text.trim().isEmpty ? null : sexCtrl.text.trim(),
            address: addressCtrl.text.trim().isEmpty
                ? null
                : addressCtrl.text.trim(),
            // Remove avatarFileUri parameter
          );

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (ok) {
        // Return to previous screen immediately
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final err = ref.read(updateProfileControllerProvider).error;
        _showErrorDialog('Không thể cập nhật thông tin', err?.toString() ?? 'Đã xảy ra lỗi không xác định');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Lỗi', 'Đã xảy ra lỗi khi cập nhật thông tin: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updating = ref.watch(updateProfileControllerProvider).isLoading;
    
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _bg,
        foregroundColor: _textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Display Only
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5E7EB),
                  border: Border.all(color: _accent, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: _textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Hồ sơ cá nhân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Form Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Thông tin cá nhân'),
                    const SizedBox(height: 16),
                    
                    // Họ và tên
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: lastCtrl,
                            label: 'Họ',
                            hintText: 'Nhập họ của bạn',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập họ'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: firstCtrl,
                            label: 'Tên',
                            hintText: 'Nhập tên của bạn',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập tên'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Giới tính và ngày sinh
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: sexCtrl,
                            label: 'Giới tính',
                            hintText: 'Nam/Nữ',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: dobCtrl,
                            label: 'Ngày sinh',
                            hintText: 'dd/MM/yyyy',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today, size: 20, color: _textSecondary),
                              onPressed: () {
                                // TODO: Show date picker
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Số điện thoại
                    _buildTextField(
                      controller: phoneCtrl,
                      label: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    
                    // Địa chỉ
                    _buildTextField(
                      controller: addressCtrl,
                      label: 'Địa chỉ',
                      hintText: 'Nhập địa chỉ của bạn',
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: updating ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: updating
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'LƯU THAY ĐỔI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
    );
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: _danger,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, color: _textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _danger, width: 1.5),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
