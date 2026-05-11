import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'thought_drop',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (authState.user == null)
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignInPage()),
              ),
              child: Text(
                'Sign In',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        child: feedState.isLoading && feedState.quotes.isEmpty
            ? Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : feedState.quotes.isEmpty
                ? _EmptyFeed()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 120),
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
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: AppColors.textPrimary),
          onPressed: () => _openCreateQuote(context),
        ),
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
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit',
              style: GoogleFonts.inter(
                fontSize: 20, 
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 220,
              autofocus: true,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Edit your thought...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
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
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String quoteId) {
    showDialog(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Quote', 
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this thought?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref.read(quoteProvider.notifier)
                  .deleteQuote(quoteId);
              if (success) {
                ref.read(feedProvider.notifier).refresh();
              }
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
            const SizedBox(height: 24),
            Text(
              'No thoughts yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share a thought',
              style: GoogleFonts.inter(
                fontSize: 15,
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
