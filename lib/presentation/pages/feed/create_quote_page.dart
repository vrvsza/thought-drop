import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'New Thought',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _canPost && !quoteState.isLoading ? _handlePost : null,
            child: quoteState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                : Text(
                    'Share',
                    style: TextStyle(
                      color: _canPost ? AppColors.accent : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  maxLength: AppConstants.maxQuoteLength,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    height: 1.7,
                    color: AppColors.textPrimary,
                  ),
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) =>
                      null,
                  decoration: InputDecoration(
                    hintText: 'Share a thought...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.divider, width: 0.5),
                  ),
                ),
                child: _PostLimitInfo(
                  todayCount: quoteState.todayPostCount,
                  maxPerDay: AppConstants.maxPostsPerDay,
                  cooldownMessage: quoteState.getCooldownMessage(),
                ),
              ),
              if (quoteState.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  quoteState.error!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 24),
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
        const SizedBox(width: 6),
        Text(
          cooldownMessage ?? '$todayCount / $maxPerDay posts today',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
