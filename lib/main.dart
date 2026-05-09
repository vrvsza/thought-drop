import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/auth_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ThoughtDropApp(),
    ),
  );
}

class ThoughtDropApp extends ConsumerStatefulWidget {
  const ThoughtDropApp({super.key});

  @override
  ConsumerState<ThoughtDropApp> createState() => _ThoughtDropAppState();
}

class _ThoughtDropAppState extends ConsumerState<ThoughtDropApp> {
  @override
  void initState() {
    super.initState();
    // Check for existing session
    Future.microtask(() {
      ref.read(authStateProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'thought_drop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
