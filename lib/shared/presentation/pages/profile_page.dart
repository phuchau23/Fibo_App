import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:swp_app/features/profile/presentation/blocs/profile_providers.dart';
import 'package:swp_app/features/profile/domain/entities/user_profile.dart';
import 'package:swp_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:swp_app/features/profile/presentation/pages/change_password_page.dart';

/// ===== FPT Blue tone (bản xanh dương) =====
const _bg = Color(0xFFF6F7F9);
const _textPrimary = Color(0xFF111827);
const _textSecondary = Color(0xFF6B7280);
const _divider = Color(0xFFE5E7EB);

const _fptBlue = Color(0xFF0072BC);
const _fptBlueSoft = Color(0xFFE6F2FB);
const _accent = Color(0xFFFF8C42);
const _danger = Color(0xFFE11D48);
const _cardRadius = 18.0;

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: _AppBackground(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: profileAsync.when(
              data: (p) => _Content(profile: p),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({required this.profile});
  final UserProfile profile;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool notificationOn = true;

  void _showFullInfoSheet(UserProfile p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _FrostedSheet(
          child: DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, controller) {
              return _FullInfoContent(
                profile: p,
                scrollController: controller,
                onEditTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          pinned: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'Hồ Sơ Của Bạn',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _accent,
                fontSize: 28,
                letterSpacing: .2,
              ),
            ),
          ),
          foregroundColor: _textPrimary,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ===== Card Info (bấm để mở full info lướt lên) =====
              InkWell(
                onTap: () => _showFullInfoSheet(p),
                borderRadius: BorderRadius.circular(_cardRadius),
                child: _Card(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundImage: AssetImage(
                          'assets/avatar_placeholder.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.male,
                                  size: 16,
                                  color: _textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    p.sex ?? '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: _textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const _SectionHeader('Tổng Quan'),
              _Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _SettingRow(
                        icon: Icons.edit_outlined,
                        iconColor: _accent,
                        title: 'Chỉnh sửa thông tin',
                        subtitle: 'Thay đổi ảnh đại diện, số điện thoại, email',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        ),
                      ),
                      const _ThinDivider(),
                      _SettingRow(
                        icon: Icons.lock_outline,
                        iconColor: _accent,
                        title: 'Thay đổi mật khẩu',
                        subtitle: 'Cập nhật và tăng cường an ninh tài khoản',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        ),
                      ),
                      const _ThinDivider(),
                      _SettingRow(
                        iconColor: _accent,
                        icon: Icons.description_outlined,
                        title: 'Điều khoản sử dụng',
                        subtitle: 'Bảo vệ tài khoản của bạn',
                        onTap: () => context.push('/profile/terms'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),
              const _SectionHeader('Preferences'),
              _Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _SettingRow.custom(
                        iconColor: _accent,
                        leading: const _IconBadge(
                          icon: Icons.notifications_outlined,
                          bg: Color(0xFFFFF3E9),
                          iconColor: _accent,
                        ),
                        title: 'Thông báo',
                        subtitle: 'Tùy chỉnh thông báo',
                        trailing: Switch(
                          value: notificationOn,
                          activeColor: _accent,
                          onChanged: (v) => setState(() => notificationOn = v),
                        ),
                        onTap: () =>
                            setState(() => notificationOn = !notificationOn),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),
              _Card(
                child: _SettingRow.custom(
                  iconColor: _accent,
                  leading: const _IconBadge(
                    icon: Icons.logout_outlined,
                    bg: Color(0xFFFFEFED),
                    iconColor: _danger,
                  ),
                  title: 'Đăng xuất',
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _danger,
                  ),
                  subtitle: 'Đăng xuất tài khoản',
                  subtitleStyle: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: _textSecondary,
                  ),
                  onTap: () => context.push('/profile/logout'),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

/// ====== Full Info Bottom Sheet Content ======
class _FullInfoContent extends StatelessWidget {
  const _FullInfoContent({
    required this.profile,
    required this.scrollController,
    required this.onEditTap,
  });

  final UserProfile profile;
  final ScrollController scrollController;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Thông tin chi tiết',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEditTap,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Chỉnh sửa'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Header với avatar
                _Card(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundImage: AssetImage(
                          'assets/avatar_placeholder.png',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.male,
                                  size: 16,
                                  color: _textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  profile.sex ?? '—',
                                  style: const TextStyle(color: _textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Thông tin chi tiết
                _InfoTile(
                  icon: Icons.phone_rounded,
                  label: 'Số điện thoại',
                  value: profile.phoneNumber ?? '—',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: profile.email,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Địa chỉ',
                  value: profile.address ?? '—',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Ngày sinh',
                  value: profile.dateOfBirth ?? '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: icon, bg: _fptBlueSoft, iconColor: _fptBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== Building blocks ======
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: _textPrimary,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({super.key, this.child, this.children, this.padding});
  final Widget? child;
  final List<Widget>? children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content =
        child ??
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 2),
          child: Column(children: children ?? const []),
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: content),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    this.bg = _fptBlueSoft,
    this.iconColor = _fptBlue,
  });

  final IconData icon;
  final Color bg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = _accent,
  }) : leading = null,
       trailing = null,
       titleStyle = null,
       subtitleStyle = null;

  const _SettingRow.custom({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.titleStyle,
    this.subtitleStyle,
    this.iconColor = _accent,
  }) : icon = null;

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final Widget leadingWidget =
        leading ??
        (icon != null
            ? _IconBadge(
                icon: icon!,
                bg: const Color(0xFFFFF3E9),
                iconColor: iconColor,
              )
            : const SizedBox(width: 38, height: 38));

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_cardRadius),
        topRight: Radius.circular(_cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            leadingWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        titleStyle ??
                        const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _textPrimary,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        subtitleStyle ??
                        const TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                          height: 1.25,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ?? const Icon(Icons.chevron_right, color: _textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.only(start: 64),
      child: Divider(height: 1, thickness: 0.8, color: _divider),
    );
  }
}

/// ===== nền ảnh + gradient =====
class _AppBackground extends StatelessWidget {
  final Widget child;
  const _AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SafeArea(
            top: true,
            bottom: true,
            left: false,
            right: false,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Image.asset('assets/images/bg_header_2.jpg'),
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 10),
                            Colors.white.withValues(alpha: 0.70),
                            Colors.white.withValues(alpha: 0.70),
                            Colors.white.withValues(alpha: 10),
                          ],
                          stops: const [0.0, 0.35, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Hiệu ứng “kính mờ” nhẹ cho sheet nền trong suốt
class _FrostedSheet extends StatelessWidget {
  const _FrostedSheet({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        // nền tối nhẹ phía sau
      ),
      child: child,
    );
  }
}
