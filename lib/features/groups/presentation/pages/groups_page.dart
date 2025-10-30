import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/groups/groups_module.dart';
import 'package:swp_app/features/groups/presentation/blocs/group_providers.dart';
import 'package:swp_app/features/groups/presentation/pages/group_detail_page.dart';
import 'package:swp_app/features/groups/presentation/widgets/CreateGroupDialog.dart';

final groupSearchQueryProvider = StateProvider<String>((ref) => '');

class GroupsPage extends ConsumerWidget {
  final String classId;
  const GroupsPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsByClassProvider(classId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: Column(
        children: [
          // ===== Top spacing để UI thoáng hơn =====
          const SizedBox(height: 20),

          // ===== Tiêu đề hoặc padding thay vì search bar =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Danh sách nhóm',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9B4A00), // nâu cam đậm
                letterSpacing: .3,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Grid Cards =====
          Expanded(
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Text(
                  'Đã xảy ra lỗi: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (groups) {
                if (groups.isEmpty) {
                  return const Center(child: Text('Chưa có nhóm nào.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: groups.length,
                  itemBuilder: (ctx, i) {
                    final g = groups[i];
                    return _GroupCard(
                      name: g.name,
                      desc: g.description ?? '',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GroupDetailPage(classId: classId, group: g),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ===== Nút tạo nhóm =====
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                  backgroundColor: const Color(0xFFFF8C42),
                  onPressed: () async {
                    final created = await showDialog<bool>(
                      context: context,
                      builder: (_) => CreateGroupDialog(classId: classId),
                    );
                    if (created == true) {
                      ref.invalidate(groupsByClassProvider(classId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tạo nhóm thành công')),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.group_add_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Tạo nhóm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===============================
 *  CARD TONE CAM – DỄ ĐỌC – ĐẸP
 * =============================== */

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.name,
    required this.desc,
    required this.onTap,
  });

  final String name;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '#';

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFB26B), // cam sáng
              Color(0xFFFFE4C1), // kem nhạt
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // avatar chữ cái
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(.6),
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9B4A00), // nâu cam đậm dễ đọc
                  ),
                ),
              ),
              const Spacer(),
              // tên nhóm
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF732C00), // nâu sậm hơn cho contrast
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              // mô tả
              if (desc.isNotEmpty)
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8C4B00).withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
