import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/features/topic/presentation/blocs/topics_providers.dart';
import 'package:swp_app/features/topic/presentation/widgets/topic_card_item.dart';
import 'package:swp_app/features/topic/presentation/widgets/topic_detail_sheet.dart';

class MyTopicTabBody extends ConsumerStatefulWidget {
  const MyTopicTabBody({super.key});

  @override
  ConsumerState<MyTopicTabBody> createState() => _MyTopicTabBodyState();
}

class _MyTopicTabBodyState extends ConsumerState<MyTopicTabBody> {
  Future<void> _refetch() async {
    final lecturerId = await ref.read(lecturerIdProvider.future);
    if (lecturerId == null) return;

    final st = ref.read(myTopicsNotifierProvider);
    final p = st.page?.currentPage ?? 1;
    await ref
        .read(myTopicsNotifierProvider.notifier)
        .fetch(page: p, lecturerId: lecturerId);
  }

  @override
  void initState() {
    super.initState();
    print('🟣 [MyTopicTabBody] initState() called');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('🟣 [MyTopicTabBody] postFrameCallback executed');
      try {
        print('🟣 [MyTopicTabBody] Reading lecturerIdProvider...');
        final lecturerId = await ref.read(lecturerIdProvider.future);
        print('🟣 [MyTopicTabBody] lecturerId: $lecturerId');
        if (lecturerId != null) {
          final st = ref.read(myTopicsNotifierProvider);
          print(
            '🟣 [MyTopicTabBody] Current state: loading=${st.loading}, hasPage=${st.page != null}, error=${st.error}',
          );
          // Fetch nếu chưa có page (bất kể loading state)
          // Vì constructor khởi tạo với loading=true nhưng chưa fetch
          if (st.page == null) {
            print('🟣 [MyTopicTabBody] Triggering fetch (page is null)...');
            ref
                .read(myTopicsNotifierProvider.notifier)
                .fetch(page: 1, lecturerId: lecturerId);
          } else {
            print(
              '🟣 [MyTopicTabBody] Skipping fetch: already has page with ${st.page!.items.length} items',
            );
          }
        } else {
          print('❌ [MyTopicTabBody] lecturerId is null!');
        }
      } catch (e, stackTrace) {
        print('❌ [MyTopicTabBody] Error in postFrameCallback: $e');
        print('❌ [MyTopicTabBody] StackTrace: $stackTrace');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🟣 [MyTopicTabBody] build() called');
    final lecturerIdAsync = ref.watch(lecturerIdProvider);
    final st = ref.watch(myTopicsNotifierProvider);
    print(
      '🟣 [MyTopicTabBody] lecturerIdAsync: ${lecturerIdAsync.isLoading
          ? "loading"
          : lecturerIdAsync.hasValue
          ? "hasValue"
          : "error"}',
    );
    print(
      '🟣 [MyTopicTabBody] state: loading=${st.loading}, hasPage=${st.page != null}, error=${st.error}',
    );

    return lecturerIdAsync.when(
      data: (lecturerId) {
        print('🟣 [MyTopicTabBody] lecturerIdAsync.data: $lecturerId');
        if (lecturerId == null) {
          print('❌ [MyTopicTabBody] Showing "Lecturer ID not found" message');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    color: Colors.grey,
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Không tìm thấy Lecturer ID',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (st.loading && st.page == null) {
          print('🟣 [MyTopicTabBody] Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        }
        if ((st.error ?? '').isNotEmpty) {
          print('❌ [MyTopicTabBody] Showing error: ${st.error}');
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
                    'Lỗi tải My Topics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                    onPressed: () => _refetch(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (st.page == null || st.page!.items.isEmpty) {
          print('🟣 [MyTopicTabBody] Showing empty state');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    color: Colors.grey,
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có Topic nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bạn chưa được phân công Topic nào',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        final page = st.page!;
        print(
          '🟣 [MyTopicTabBody] Showing list with ${page.items.length} items',
        );
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
      },
      loading: () {
        print('🟣 [MyTopicTabBody] lecturerIdAsync is loading...');
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        print('❌ [MyTopicTabBody] lecturerIdAsync error: $err');
        print('❌ [MyTopicTabBody] StackTrace: $stack');
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
                  'Lỗi tải Lecturer ID',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
