import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider profile của bạn
import 'package:swp_app/features/notification/presentation/widgets/notification_icon.dart';
import 'package:swp_app/features/profile/presentation/blocs/profile_providers.dart';
import 'package:swp_app/shared/presentation/providers/navigation_provider.dart';
import 'package:swp_app/shared/presentation/widgets/dashboard_widget.dart';
import 'package:google_fonts/google_fonts.dart';

// ===== Theme =====
const _navy = Color.fromARGB(255, 255, 231, 207);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final prof = ref.watch(profileNotifierProvider);

    final name = prof.when(
      data: (u) {
        final first = u.firstname ?? '';
        final last = u.lastname ?? '';
        final full = [first, last].where((e) => e.isNotEmpty).join(' ');
        return full.isEmpty ? 'User' : full;
      },
      loading: () => '…',
      error: (_, __) => 'User',
    );
    final avatarUrl = prof.when(
      data: (u) => u.avatarUrl,
      loading: () => null,
      error: (_, __) => null,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _navy,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // ===== 1) HELLO =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color.fromARGB(87, 255, 167, 84),
                        backgroundImage:
                            (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                            ? const Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 255, 102, 0),
                                size: 18,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Hello!',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 102, 0),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 2),
                          ],
                        ),
                      ),
                      const NotificationIcon(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 102, 0),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ===== DASHBOARD SECTION =====
                const DashboardWidget(),
                const SizedBox(height: 40),
                // ===== QUICK ACTIONS SECTION =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Quick Actions',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.people_alt_outlined,
                          title: 'Classes',
                          color: const Color(0xFF2563EB),
                          onTap: () {
                            ref
                                .read(navigationRequestProvider.notifier)
                                .state = const NavigationRequest(
                              target: NavigationTarget.classList,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.receipt_long,
                          title: 'Topics',
                          color: const Color(0xFF22C55E),
                          onTap: () {
                            ref
                                .read(navigationRequestProvider.notifier)
                                .state = const NavigationRequest(
                              target: NavigationTarget.topic,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.menu_book_outlined,
                          title: 'Course',
                          color: const Color(0xFFF97316),
                          onTap: () {
                            ref
                                .read(navigationRequestProvider.notifier)
                                .state = const NavigationRequest(
                              target: NavigationTarget.course,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101828),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
