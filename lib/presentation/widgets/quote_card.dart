import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../data/models/quote_model.dart';

class QuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback? onLike;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const QuoteCard({
    super.key,
    required this.quote,
    this.onLike,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Username and timestamp
            Row(
              children: [
                // Avatar placeholder
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Text(
                    (quote.username ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.username ?? 'Anonymous',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        app_date.DateUtils.formatRelativeTime(quote.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Quote content
            Text(
              quote.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
            // Actions row: Like button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _LikeButton(
                  isLiked: quote.isLiked,
                  likesCount: quote.likesCount,
                  onTap: onLike,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0, duration: 300.ms);
  }
}

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback? onTap;

  const _LikeButton({
    required this.isLiked,
    required this.likesCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: isLiked ? AppColors.likeActive : AppColors.textTertiary,
            ).animate(target: isLiked ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: 150.ms,
            ).then().scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(1, 1),
              duration: 150.ms,
            ),
            const SizedBox(width: 4),
            Text(
              likesCount > 0 ? '$likesCount' : '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isLiked ? AppColors.likeActive : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
