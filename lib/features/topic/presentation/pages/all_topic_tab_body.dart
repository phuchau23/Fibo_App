import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';
import 'package:swp_app/features/topic/presentation/widgets/topic_card_item.dart';
import 'package:swp_app/features/topic/presentation/widgets/topic_detail_sheet.dart';

class AllTopicTabBody extends ConsumerStatefulWidget {
  const AllTopicTabBody({super.key});

  @override
  ConsumerState<AllTopicTabBody> createState() => _AllTopicTabBodyState();
}

class _AllTopicTabBodyState extends ConsumerState<AllTopicTabBody> {
  Future<void> _refetch() async {
    final st = ref.read(topicsNotifierProvider);
    final p = st.page?.currentPage ?? 1;
    await ref.read(topicsNotifierProvider.notifier).fetch(page: p);
  }

  @override
  void initState() {
    super.initState();
    print('🟢 [AllTopicTabBody] initState() called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🟢 [AllTopicTabBody] postFrameCallback executed');
      final st = ref.read(topicsNotifierProvider);
      print(
        '🟢 [AllTopicTabBody] Current state: loading=${st.loading}, hasPage=${st.page != null}, error=${st.error}',
      );
      if (st.page == null && !st.loading) {
        print('🟢 [AllTopicTabBody] Triggering fetch...');
        ref.read(topicsNotifierProvider.notifier).fetch(page: 1);
      } else {
        print(
          '🟢 [AllTopicTabBody] Skipping fetch: page=${st.page != null}, loading=${st.loading}',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(topicsNotifierProvider);
    print(
      '🟢 [AllTopicTabBody] build() - loading=${st.loading}, hasPage=${st.page != null}, error=${st.error}',
    );

    if (st.loading && st.page == null) {
      print('🟢 [AllTopicTabBody] Showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }
    if ((st.error ?? '').isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 8),
              Text(
                'Lỗi tải Topics',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                st.error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(topicsNotifierProvider.notifier).fetch(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final page = st.page!;
    return RefreshIndicator(
      onRefresh: _refetch,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: page.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final t = page.items[i];
          return TopicCardItem(
            item: t,
            onTap: () => showTopicDetailsSheet(context, t),
          );
        },
      ),
    );
  }
}
