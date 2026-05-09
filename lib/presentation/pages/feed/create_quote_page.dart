import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/quote_provider.dart';

class CreateQuotePage extends ConsumerStatefulWidget {
  const CreateQuotePage({super.key});

  @override
  ConsumerState<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends ConsumerState<CreateQuotePage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quoteProvider.notifier).checkPostLimit();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _charCount => _controller.text.trim().length;
  bool get _canPost => _canSubmit && _charCount >= AppConstants.minQuoteLength;

  bool get _canSubmit {
    final quoteState = ref.read(quoteProvider);
    return quoteState.canPost;
  }

  Future<void> _handlePost() async {
    if (!_canPost) return;

    final success = await ref.read(quoteProvider.notifier).createQuote(
      _controller.text,
    );

    if (success) {
      ref.read(feedProvider.notifier).refresh();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Thought'),
        actions: [
          TextButton(
            onPressed: _canPost && !quoteState.isLoading ? _handlePost : null,
            child: quoteState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Share'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  maxLength: AppConstants.maxQuoteLength,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) =>
                      null,
                  decoration: const InputDecoration(
                    hintText: 'Share a thought...',
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              _PostLimitInfo(
                todayCount: quoteState.todayPostCount,
                maxPerDay: AppConstants.maxPostsPerDay,
                cooldownMessage: quoteState.getCooldownMessage(),
              ),
              if (quoteState.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  quoteState.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PostLimitInfo extends StatelessWidget {
  final int todayCount;
  final int maxPerDay;
  final String? cooldownMessage;

  const _PostLimitInfo({
    required this.todayCount,
    required this.maxPerDay,
    this.cooldownMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          todayCount >= maxPerDay ? Icons.warning : Icons.schedule,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          cooldownMessage ?? '$todayCount / $maxPerDay posts today',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
