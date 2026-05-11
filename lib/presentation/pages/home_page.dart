import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'feed/feed_page.dart';
import 'profile/profile_page.dart';

final _currentIndexProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_currentIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          FeedPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _FloatingNavDock(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(_currentIndexProvider.notifier).state = index,
        onCreateTap: () {
          // Navigate to create quote - will be implemented
        },
      ),
    );
  }
}

class _FloatingNavDock extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCreateTap;

  const _FloatingNavDock({
    required this.currentIndex,
    required this.onTap,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home button
            _NavIcon(
              icon: currentIndex == 0 ? Icons.home : Icons.home_outlined,
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            // Explore button
            _NavIcon(
              icon: Icons.search_outlined,
              isSelected: false,
              onTap: () {},
            ),
            // Create button (centered, raised)
            _CreateButton(onTap: onCreateTap),
            // Profile button
            _NavIcon(
              icon: currentIndex == 1 ? Icons.person : Icons.person_outline,
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // More button
            _NavIcon(
              icon: Icons.more_horiz,
              isSelected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? AppColors.accent : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          size: 26,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
