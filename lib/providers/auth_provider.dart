import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  initial,
  guest,
  authenticated,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? error;

  AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.displayName,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> initializeAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final email = prefs.getString('user_email');
      final displayName = prefs.getString('user_display_name');
      
      if (userId != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: userId,
          email: email,
          displayName: displayName,
        );
      } else {
        final isGuest = prefs.getBool('is_guest') ?? false;
        state = state.copyWith(
          status: isGuest ? AuthStatus.guest : AuthStatus.initial,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  bool isFirstLaunch() {
    // This is a simplified check - in production you'd use SharedPreferences
    return true; // For demo purposes, always show first launch modal
  }

  Future<void> continueAsGuest() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
      await prefs.setBool('first_launch_complete', true);
      
      state = state.copyWith(status: AuthStatus.guest);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      // TODO: Implement actual authentication logic
      // For now, simulate successful login
      await Future.delayed(const Duration(seconds: 2));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', 'demo_user_id');
      await prefs.setString('user_email', email);
      await prefs.setString('user_display_name', email.split('@')[0]);
      await prefs.setBool('first_launch_complete', true);
      await prefs.setBool('is_guest', false);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: 'demo_user_id',
        email: email,
        displayName: email.split('@')[0],
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      // TODO: Implement actual signup logic
      // For now, simulate successful signup
      await Future.delayed(const Duration(seconds: 2));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', 'demo_user_id');
      await prefs.setString('user_email', email);
      await prefs.setString('user_display_name', name);
      await prefs.setBool('first_launch_complete', true);
      await prefs.setBool('is_guest', false);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: 'demo_user_id',
        email: email,
        displayName: name,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_display_name');
      await prefs.setBool('is_guest', true);
      
      state = state.copyWith(
        status: AuthStatus.guest,
        userId: null,
        email: null,
        displayName: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

final currentUserProvider = Provider<Map<String, String>?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.status == AuthStatus.authenticated && authState.userId != null) {
    return {
      'id': authState.userId!,
      'email': authState.email ?? '',
      'displayName': authState.displayName ?? '',
    };
  }
  return null;
});
