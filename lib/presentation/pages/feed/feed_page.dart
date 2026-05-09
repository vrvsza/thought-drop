import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/quote_card.dart';
import '../auth/sign_in_page.dart';
import 'create_quote_page.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(feedProvider.notifier).loadInitialFeed();
    });
  }

  Future<void> _handleRefresh() async {
    await ref.read(feedProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('thought_drop'),
        actions: [
          if (authState.user == null)
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignInPage()),
              ),
              child: const Text('Sign In'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.accent,
        child: feedState.isLoading && feedState.quotes.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : feedState.quotes.isEmpty
                ? _EmptyFeed()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: feedState.quotes.length,
                    itemBuilder: (context, index) {
                      final quote = feedState.quotes[index];
                      final isOwn = authState.user != null && 
                          quote.userId == authState.user!.id;
                      
                      return QuoteCard(
                        quote: quote,
                        showActions: isOwn,
                        onLike: () {
                          if (authState.user == null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignInPage(),
                              ),
                            );
                            return;
                          }
                          ref.read(feedProvider.notifier).toggleLike(quote.id);
                        },
                        onEdit: () => _showEditDialog(quote.id, quote.content),
                        onDelete: () => _confirmDelete(quote.id),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateQuote(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openCreateQuote(BuildContext context) {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateQuotePage()),
    );
  }

  void _showEditDialog(String quoteId, String currentContent) {
    final controller = TextEditingController(text: currentContent);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 220,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Edit your thought...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final success = await ref.read(quoteProvider.notifier)
                        .updateQuote(quoteId, controller.text);
                    if (success) {
                      ref.read(feedProvider.notifier).refresh();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String quoteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: const Text('Are you sure you want to delete this quote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref.read(quoteProvider.notifier)
                  .deleteQuote(quoteId);
              if (success) {
                ref.read(feedProvider.notifier).refresh();
              }
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_quote,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No thoughts yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share a thought',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
