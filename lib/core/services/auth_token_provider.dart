// lib/features/auth/presentation/providers/auth_providers.dart (thêm)
import 'package:swp_app/core/services/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final session = ref.watch(sessionServiceProvider);
  return session.userId;
});

final currentTokenProvider = FutureProvider<String?>((ref) async {
  final session = ref.watch(sessionServiceProvider);
  return session.token;
});


// ví dụ ở đâu đó trong repo/datasource
// final uid = await ref.read(sessionServiceProvider).userId;
// GET /users/{uid}/classes