import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_service.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/profile_model.dart';
import 'auth_provider.dart';

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.read(localDataSourceProvider), ref.read(authStateProvider));
});

class FeedState {
  final List<QuoteModel> quotes;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.quotes = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({
    List<QuoteModel>? quotes,
    bool? isLoading,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      quotes: quotes ?? this.quotes,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final LocalDataSource _dataSource;
  final AuthState _authState;

  FeedNotifier(this._dataSource, this._authState) : super(const FeedState());

  Future<void> loadInitialFeed() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      var quotesData = await _dataSource.getQuotes();
      
      // If no quotes, add seed quotes
      if (quotesData.isEmpty) {
        quotesData = _generateSeedQuotes();
        await _dataSource.saveQuotes(quotesData);
      }

      final userId = _authState.user?.id;
      final quotes = await _mapQuotesWithLikes(quotesData, userId);
      final sortedQuotes = _rankQuotes(quotes);

      state = state.copyWith(
        quotes: sortedQuotes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(quotes: [], hasMore: true);
    await loadInitialFeed();
  }

  List<Map<String, dynamic>> _generateSeedQuotes() {
    final now = DateTime.now();
    final seedQuotes = [
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-1',
        'content': 'The only way to do great work is to love what you do.',
        'likes_count': 42,
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'username': 'Steve Jobs',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-2',
        'content': 'In the middle of difficulty lies opportunity.',
        'likes_count': 38,
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'username': 'Einstein',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-3',
        'content': 'Be yourself; everyone else is already taken.',
        'likes_count': 56,
        'created_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'username': 'Oscar Wilde',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-4',
        'content': 'The unexamined life is not worth living.',
        'likes_count': 29,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'username': 'Socrates',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-5',
        'content': 'We are what we repeatedly do. Excellence, then, is not an act but a habit.',
        'likes_count': 45,
        'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'username': 'Aristotle',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-6',
        'content': 'The mind is everything. What you think you become.',
        'likes_count': 33,
        'created_at': now.subtract(const Duration(hours: 18)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 18)).toIso8601String(),
        'username': 'Buddha',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-7',
        'content': 'Simplicity is the ultimate sophistication.',
        'likes_count': 51,
        'created_at': now.subtract(const Duration(hours: 24)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 24)).toIso8601String(),
        'username': 'Da Vinci',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-8',
        'content': 'Quiet the mind, and the soul will speak.',
        'likes_count': 27,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'username': 'Ma Jaya',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-9',
        'content': 'Love is not about how many people you meet, but how many people you can never forget.',
        'likes_count': 19,
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'username': 'Gibran',
        'avatar_url': null,
      },
      {
        'id': const Uuid().v4(),
        'user_id': 'seed-10',
        'content': 'The wound is the place where the Light enters you.',
        'likes_count': 31,
        'created_at': now.subtract(const Duration(days: 1, hours: 6)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 1, hours: 6)).toIso8601String(),
        'username': 'Rumi',
        'avatar_url': null,
      },
    ];
    return seedQuotes;
  }

  Future<List<QuoteModel>> _mapQuotesWithLikes(
    List<Map<String, dynamic>> quotesData,
    String? userId,
  ) async {
    final quotes = <QuoteModel>[];
    for (final q in quotesData) {
      bool isLiked = false;
      if (userId != null) {
        isLiked = await _dataSource.isLiked(userId, q['id'] as String);
      }
      quotes.add(QuoteModel.fromMap({
        ...q,
        'is_liked': isLiked,
      }));
    }
    return quotes;
  }

  List<QuoteModel> _rankQuotes(List<QuoteModel> quotes) {
    // 70% ranked by score, 20% recent, 10% random exploration
    final ranked = List<QuoteModel>.from(quotes)
      ..sort((a, b) => b.rankingScore.compareTo(a.rankingScore));
    
    final rankedCount = (quotes.length * AppConstants.rankedFeedRatio).floor();
    final recentCount = (quotes.length * AppConstants.recentFeedRatio).floor();
    final exploreCount = (quotes.length * AppConstants.explorationFeedRatio).floor();

    final rankedQuotes = ranked.take(rankedCount).toList();
    final recentQuotes = List<QuoteModel>.from(quotes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final exploreQuotes = List<QuoteModel>.from(quotes)..shuffle();

    final result = <QuoteModel>[
      ...rankedQuotes,
      ...recentQuotes.take(recentCount),
      ...exploreQuotes.take(exploreCount),
    ];

    // Remove duplicates while preserving order
    final seen = <String>{};
    return result.where((q) => seen.add(q.id)).toList();
  }

  Future<void> toggleLike(String quoteId) async {
    if (_authState.user == null) return;

    final userId = _authState.user!.id;
    final quoteIndex = state.quotes.indexWhere((q) => q.id == quoteId);
    if (quoteIndex == -1) return;

    final quote = state.quotes[quoteIndex];
    final isCurrentlyLiked = quote.isLiked;

    // Optimistic update
    final updatedQuotes = List<QuoteModel>.from(state.quotes);
    updatedQuotes[quoteIndex] = quote.copyWith(
      isLiked: !isCurrentlyLiked,
      likesCount: isCurrentlyLiked ? quote.likesCount - 1 : quote.likesCount + 1,
    );
    state = state.copyWith(quotes: updatedQuotes);

    // Persist
    try {
      if (isCurrentlyLiked) {
        await _dataSource.removeLike(userId, quoteId);
      } else {
        await _dataSource.addLike({
          'id': const Uuid().v4(),
          'user_id': userId,
          'quote_id': quoteId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
      // Update quote likes count in storage
      final quotesData = await _dataSource.getQuotes();
      final idx = quotesData.indexWhere((q) => q['id'] == quoteId);
      if (idx != -1) {
        final currentLikes = quotesData[idx]['likes_count'] as int? ?? 0;
        quotesData[idx]['likes_count'] = isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1;
        await _dataSource.saveQuotes(quotesData);
      }
    } catch (e) {
      // Revert on error
      state = state.copyWith(quotes: state.quotes);
    }
  }
}
