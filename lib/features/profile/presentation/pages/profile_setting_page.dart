// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:swp_app/features/profile/presentation/blocs/profile_providers.dart';
// import 'package:swp_app/features/profile/domain/entities/user_profile.dart';

// class ProfileSettingPage extends ConsumerWidget {
//   const ProfileSettingPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final profileAsync = ref.watch(profileNotifierProvider);
//     const bg = Color(0xFFF9FAFB);

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         backgroundColor: bg,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'PROFILE SETTING',
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//             fontSize: 16,
//           ),
//         ),
//       ),
//       body: profileAsync.when(
//         data: (p) => _Content(profile: p),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }

// class _Content extends StatefulWidget {
//   const _Content({required this.profile});
//   final UserProfile profile;

//   @override
//   State<_Content> createState() => _ContentState();
// }

// class _ContentState extends State<_Content> {
//   bool notificationOn = true;

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.profile;

//     return ListView(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
//       children: [
//         // ===== Profile card =====
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: _cardDecoration,
//           child: Row(
//             children: [
//               const CircleAvatar(
//                 radius: 28,
//                 backgroundImage: AssetImage('assets/avatar_placeholder.png'),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       p.fullName,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       p.email,
//                       style: const TextStyle(fontSize: 13, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),

//         // ===== General =====
//         const _SectionTitle('General'),
//         _Card(
//           children: [
//             _Tile(
//               icon: Icons.edit_outlined,
//               title: 'Edit Profile',
//               subtitle: 'Change profile picture, number, E-mail',
//               onTap: () => context.push('/profile/edit'),
//             ),
//             const _Divider(),
//             _Tile(
//               icon: Icons.lock_outline,
//               title: 'Change Password',
//               subtitle: 'Update and strengthen account security',
//               onTap: () => context.push('/profile/change-password'),
//             ),
//             const _Divider(),
//             _Tile(
//               icon: Icons.description_outlined,
//               title: 'Terms of Use',
//               subtitle: 'Protect your account now',
//               onTap: () => context.push('/profile/terms'),
//             ),
//             const _Divider(),
//             _Tile(
//               icon: Icons.credit_card_outlined,
//               title: 'Add Card',
//               subtitle: 'Securely add payment method',
//               onTap: () => context.push('/profile/add-card'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),

//         // ===== Preferences =====
//         const _SectionTitle('Preferences'),
//         _Card(
//           children: [
//             ListTile(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 4,
//               ),
//               leading: const Icon(
//                 Icons.notifications_outlined,
//                 color: Color(0xFF3B82F6),
//               ),
//               title: const Text(
//                 'Notification',
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//               subtitle: const Text(
//                 'Customize your notification preferences',
//                 style: TextStyle(color: Colors.grey, fontSize: 13),
//               ),
//               trailing: Switch(
//                 value: notificationOn,
//                 activeColor: const Color(0xFF3B82F6),
//                 onChanged: (v) => setState(() => notificationOn = v),
//               ),
//             ),
//             const _Divider(),
//             _Tile(
//               icon: Icons.help_outline,
//               title: 'FAQ',
//               subtitle: 'Common questions and answers',
//               onTap: () => context.push('/profile/faq'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),

//         // ===== Logout (placeholder) =====
//         _Card(
//           children: [
//             ListTile(
//               onTap: () => context.push('/profile/logout'),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 4,
//               ),
//               leading: const Icon(Icons.logout_outlined, color: Colors.red),
//               title: const Text(
//                 'Log Out',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.red,
//                 ),
//               ),
//               subtitle: const Text(
//                 'Securely log out of Account',
//                 style: TextStyle(color: Colors.grey, fontSize: 13),
//               ),
//               trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   BoxDecoration get _cardDecoration => BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(16),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black12.withOpacity(0.05),
//         blurRadius: 6,
//         offset: const Offset(0, 2),
//       ),
//     ],
//   );
// }

// class _SectionTitle extends StatelessWidget {
//   const _SectionTitle(this.text);
//   final String text;
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//           fontSize: 15,
//         ),
//       ),
//       const SizedBox(height: 8),
//     ],
//   );
// }

// class _Card extends StatelessWidget {
//   const _Card({required this.children});
//   final List<Widget> children;
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black12.withOpacity(0.05),
//           blurRadius: 6,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Column(children: children),
//   );
// }

// class _Tile extends StatelessWidget {
//   const _Tile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) => ListTile(
//     onTap: onTap,
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//     leading: Icon(icon, color: const Color(0xFF3B82F6)),
//     title: Text(
//       title,
//       style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
//     ),
//     subtitle: Text(
//       subtitle,
//       style: const TextStyle(color: Colors.grey, fontSize: 13),
//     ),
//     trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//   );
// }

// class _Divider extends StatelessWidget {
//   const _Divider();
//   @override
//   Widget build(BuildContext context) =>
//       const Divider(height: 1, thickness: 0.8, indent: 16, endIndent: 16);
// }
