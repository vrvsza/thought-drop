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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Username and timestamp
            Row(
              children: [
                // Avatar placeholder - subtle dark circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (quote.username ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.username ?? 'Anonymous',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app_date.DateUtils.formatRelativeTime(quote.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz, 
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    color: AppColors.surfaceElevated,
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit', 
                        child: Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                      PopupMenuItem(
                        value: 'delete', 
                        child: Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Quote content - larger, more readable
            Text(
              quote.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                height: 1.65,
                letterSpacing: 0.15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
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
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0, duration: 400.ms);
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLiked ? AppColors.likeActive.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isLiked ? AppColors.likeActive : AppColors.textTertiary,
            ).animate(target: isLiked ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 150.ms,
            ).then().scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1, 1),
              duration: 150.ms,
            ),
            if (likesCount > 0) ...[
              const SizedBox(width: 6),
              Text(
                '$likesCount',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isLiked ? AppColors.likeActive : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
