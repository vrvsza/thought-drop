/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ThoughtDrop';
  static const String appVersion = '1.0.0';

  // Supabase - These would be replaced with actual Supabase credentials
  // For dev/demo, we'll use placeholder values
  static const String supabaseUrl = 'https://YOUR_SUPABASE_URL.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Content Limits
  static const int maxQuoteLength = 220;
  static const int minQuoteLength = 10;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;

  // Posting Limits
  static const int maxPostsPerDay = 3;
  static const int postCooldownMinutes = 30;

  // Feed
  static const int feedPageSize = 20;
  static const double rankedFeedRatio = 0.7;
  static const double recentFeedRatio = 0.2;
  static const double explorationFeedRatio = 0.1;

  // Ranking Algorithm
  // score = (likes_count + 1) / ((hours_since_posted + 2) ^ 1.5)
  static const double rankingExponent = 1.5;
  static const double rankingBase = 2.0;
}
