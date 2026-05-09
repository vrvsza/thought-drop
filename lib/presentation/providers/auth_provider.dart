import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/local_service.dart';
import '../../data/models/profile_model.dart';

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(localDataSourceProvider));
});

class AuthState {
  final ProfileModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    ProfileModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalDataSource _dataSource;

  AuthNotifier(this._dataSource) : super(const AuthState());

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userData = await _dataSource.getCurrentUser();
      if (userData != null) {
        final profile = ProfileModel.fromMap(userData);
        state = state.copyWith(user: profile, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Validate username
      if (username.length < 3 || username.length > 30) {
        state = state.copyWith(
          error: 'Username must be 3-30 characters',
          isLoading: false,
        );
        return false;
      }

      // Create user (in real app this goes to Supabase)
      final userId = const Uuid().v4();
      final now = DateTime.now();
      
      final profile = ProfileModel(
        id: userId,
        username: username,
        createdAt: now,
      );

      await _dataSource.setCurrentUser(profile.toMap());
      await _dataSource.saveProfile(profile.toMap());

      state = state.copyWith(user: profile, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // For demo, create a session from stored data
      // In real app, this validates against Supabase auth
      final userData = await _dataSource.getCurrentUser();
      
      if (userData != null) {
        final profile = ProfileModel.fromMap(userData);
        state = state.copyWith(user: profile, isLoading: false);
        return true;
      }
      
      // If no stored user, create demo session
      final userId = const Uuid().v4();
      final profile = ProfileModel(
        id: userId,
        username: email.split('@').first,
        createdAt: DateTime.now(),
      );

      await _dataSource.setCurrentUser(profile.toMap());
      await _dataSource.saveProfile(profile.toMap());

      state = state.copyWith(user: profile, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _dataSource.setCurrentUser(null);
    state = state.copyWith(clearUser: true);
  }

  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
    String? bio,
  }) async {
    if (state.user == null) return;

    final updatedProfile = state.user!.copyWith(
      username: username,
      avatarUrl: avatarUrl,
      bio: bio,
    );

    await _dataSource.saveProfile(updatedProfile.toMap());
    await _dataSource.setCurrentUser(updatedProfile.toMap());

    state = state.copyWith(user: updatedProfile);
  }
}
