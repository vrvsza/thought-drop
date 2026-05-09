import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_service.dart';
import '../../data/models/quote_model.dart';
import 'auth_provider.dart';

final quoteProvider = StateNotifierProvider<QuoteNotifier, QuoteState>((ref) {
  return QuoteNotifier(ref.read(localDataSourceProvider), ref.read(authStateProvider));
});

class QuoteState {
  final bool isLoading;
  final String? error;
  final int todayPostCount;
  final DateTime? lastPostTime;

  const QuoteState({
    this.isLoading = false,
    this.error,
    this.todayPostCount = 0,
    this.lastPostTime,
  });

  QuoteState copyWith({
    bool? isLoading,
    String? error,
    int? todayPostCount,
    DateTime? lastPostTime,
    bool clearError = false,
  }) {
    return QuoteState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      todayPostCount: todayPostCount ?? this.todayPostCount,
      lastPostTime: lastPostTime ?? this.lastPostTime,
    );
  }

  bool get canPost {
    if (todayPostCount >= AppConstants.maxPostsPerDay) return false;
    if (lastPostTime != null) {
      final cooldownEnd = lastPostTime!.add(const Duration(minutes: AppConstants.postCooldownMinutes));
      if (DateTime.now().isBefore(cooldownEnd)) return false;
    }
    return true;
  }

  String? getCooldownMessage() {
    if (lastPostTime != null) {
      final cooldownEnd = lastPostTime!.add(const Duration(minutes: AppConstants.postCooldownMinutes));
      if (DateTime.now().isBefore(cooldownEnd)) {
        final minutesLeft = cooldownEnd.difference(DateTime.now()).inMinutes;
        return 'Please wait $minutesLeft minutes between posts';
      }
    }
    return null;
  }
}

class QuoteNotifier extends StateNotifier<QuoteState> {
  final LocalDataSource _dataSource;
  final AuthState _authState;

  QuoteNotifier(this._dataSource, this._authState) : super(const QuoteState());

  Future<void> checkPostLimit() async {
    if (_authState.user == null) return;
    
    final userId = _authState.user!.id;
    final todayCount = await _dataSource.getTodayPostCount(userId);
    state = state.copyWith(todayPostCount: todayCount);
  }

  Future<bool> createQuote(String content) async {
    if (_authState.user == null) {
      state = state.copyWith(error: 'You must be signed in to post');
      return false;
    }

    if (content.trim().length < AppConstants.minQuoteLength) {
      state = state.copyWith(error: 'Quote must be at least ${AppConstants.minQuoteLength} characters');
      return false;
    }

    if (content.trim().length > AppConstants.maxQuoteLength) {
      state = state.copyWith(error: 'Quote must be less than ${AppConstants.maxQuoteLength} characters');
      return false;
    }

    if (!state.canPost) {
      final message = state.getCooldownMessage() ?? 'Daily post limit reached';
      state = state.copyWith(error: message);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userId = _authState.user!.id;
      final now = DateTime.now();
      
      final quoteMap = {
        'id': const Uuid().v4(),
        'user_id': userId,
        'content': content.trim(),
        'likes_count': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'username': _authState.user!.username,
        'avatar_url': _authState.user!.avatarUrl,
      };

      await _dataSource.addQuote(quoteMap);

      state = state.copyWith(
        isLoading: false,
        todayPostCount: state.todayPostCount + 1,
        lastPostTime: now,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<bool> updateQuote(String quoteId, String content) async {
    if (_authState.user == null) return false;

    if (content.trim().length < AppConstants.minQuoteLength ||
        content.trim().length > AppConstants.maxQuoteLength) {
      state = state.copyWith(error: 'Invalid quote length');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final quotes = await _dataSource.getQuotes();
      final index = quotes.indexWhere((q) => q['id'] == quoteId);
      
      if (index == -1) {
        state = state.copyWith(error: 'Quote not found', isLoading: false);
        return false;
      }

      if (quotes[index]['user_id'] != _authState.user!.id) {
        state = state.copyWith(error: 'You can only edit your own quotes', isLoading: false);
        return false;
      }

      quotes[index]['content'] = content.trim();
      quotes[index]['updated_at'] = DateTime.now().toIso8601String();
      
      await _dataSource.saveQuotes(quotes);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<bool> deleteQuote(String quoteId) async {
    if (_authState.user == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final quotes = await _dataSource.getQuotes();
      final index = quotes.indexWhere((q) => q['id'] == quoteId);
      
      if (index == -1) {
        state = state.copyWith(error: 'Quote not found', isLoading: false);
        return false;
      }

      if (quotes[index]['user_id'] != _authState.user!.id) {
        state = state.copyWith(error: 'You can only delete your own quotes', isLoading: false);
        return false;
      }

      await _dataSource.deleteQuote(quoteId);

      state = state.copyWith(isLoading: false, todayPostCount: state.todayPostCount - 1);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}
