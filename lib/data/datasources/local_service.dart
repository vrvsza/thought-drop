import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataSource {
  static const String _quotesKey = 'local_quotes';
  static const String _likesKey = 'local_likes';
  static const String _profilesKey = 'local_profiles';
  static const String _currentUserKey = 'current_user';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Quotes
  Future<List<Map<String, dynamic>>> getQuotes() async {
    final p = await prefs;
    final data = p.getString(_quotesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveQuotes(List<Map<String, dynamic>> quotes) async {
    final p = await prefs;
    await p.setString(_quotesKey, jsonEncode(quotes));
  }

  Future<void> addQuote(Map<String, dynamic> quote) async {
    final quotes = await getQuotes();
    quotes.insert(0, quote);
    await saveQuotes(quotes);
  }

  Future<void> updateQuote(String id, Map<String, dynamic> quote) async {
    final quotes = await getQuotes();
    final index = quotes.indexWhere((q) => q['id'] == id);
    if (index != -1) {
      quotes[index] = quote;
      await saveQuotes(quotes);
    }
  }

  Future<void> deleteQuote(String id) async {
    final quotes = await getQuotes();
    quotes.removeWhere((q) => q['id'] == id);
    await saveQuotes(quotes);
  }

  // Likes
  Future<List<Map<String, dynamic>>> getLikes() async {
    final p = await prefs;
    final data = p.getString(_likesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveLikes(List<Map<String, dynamic>> likes) async {
    final p = await prefs;
    await p.setString(_likesKey, jsonEncode(likes));
  }

  Future<bool> isLiked(String userId, String quoteId) async {
    final likes = await getLikes();
    return likes.any((l) => l['user_id'] == userId && l['quote_id'] == quoteId);
  }

  Future<void> addLike(Map<String, dynamic> like) async {
    final likes = await getLikes();
    likes.add(like);
    await saveLikes(likes);
  }

  Future<void> removeLike(String userId, String quoteId) async {
    final likes = await getLikes();
    likes.removeWhere((l) => l['user_id'] == userId && l['quote_id'] == quoteId);
    await saveLikes(likes);
  }

  // Current User
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final p = await prefs;
    final data = p.getString(_currentUserKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> setCurrentUser(Map<String, dynamic>? user) async {
    final p = await prefs;
    if (user == null) {
      await p.remove(_currentUserKey);
    } else {
      await p.setString(_currentUserKey, jsonEncode(user));
    }
  }

  // Profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final p = await prefs;
    final data = p.getString(_profilesKey);
    if (data == null) return null;
    final profiles = jsonDecode(data) as List;
    final profileList = profiles.cast<Map<String, dynamic>>();
    for (final profile in profileList) {
      if (profile['id'] == userId) return profile;
    }
    return null;
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final p = await prefs;
    List<dynamic> profilesData = [];
    final data = p.getString(_profilesKey);
    if (data != null) {
      profilesData = jsonDecode(data) as List;
    }
    final profiles = profilesData.cast<Map<String, dynamic>>();
    final index = profiles.indexWhere((pr) => pr['id'] == profile['id']);
    if (index != -1) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await p.setString(_profilesKey, jsonEncode(profiles));
  }

  // Posts count for today
  Future<int> getTodayPostCount(String userId) async {
    final quotes = await getQuotes();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int count = 0;
    for (final q in quotes) {
      final createdAt = DateTime.parse(q['created_at'] as String);
      if (q['user_id'] == userId && createdAt.isAfter(today)) {
        count++;
      }
    }
    return count;
  }

  // Clear all data
  Future<void> clear() async {
    final p = await prefs;
    await p.remove(_quotesKey);
    await p.remove(_likesKey);
    await p.remove(_profilesKey);
    await p.remove(_currentUserKey);
  }
}
