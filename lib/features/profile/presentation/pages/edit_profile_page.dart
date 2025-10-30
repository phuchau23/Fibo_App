import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/profile/presentation/blocs/profile_providers.dart';
import 'package:swp_app/features/profile/domain/entities/user_profile.dart';

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
          avatarFileUri: avatarFileUri,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).pop();
    } else {
      final err = ref.read(updateProfileControllerProvider).error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final updating = ref.watch(updateProfileControllerProvider).isLoading;
    const bg = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: Colors.black87,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstCtrl,
                          decoration: const InputDecoration(
                            labelText: 'First name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: lastCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dobCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth (yyyy-MM-dd)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: sexCtrl,
                          decoration: const InputDecoration(labelText: 'Sex'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: updating ? null : _submit,
            child: updating
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save changes'),
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
