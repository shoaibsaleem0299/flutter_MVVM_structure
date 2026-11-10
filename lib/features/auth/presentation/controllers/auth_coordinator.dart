import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class SessionState {
  const SessionState({
    this.status = AuthStatus.unknown,
    this.user,
  });

  final AuthStatus status;
  final UserModel? user;

  SessionState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool clearUser = false,
  }) =>
      SessionState(
        status: status ?? this.status,
        user: clearUser ? null : (user ?? this.user),
      );
}

/// Global Application Session Coordinator.
/// Listened to by router for navigation guards and settings for sign-out.
/// Pure Dart: zero UI controllers or widget dependencies.
class AuthCoordinator extends Notifier<SessionState> {
  IAuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  SessionState build() {
    Future.microtask(restoreSession);
    return const SessionState();
  }

  Future<void> restoreSession() async {
    try {
      final user = await _repo.restoreSession();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        );
      }
    } on NetworkFailure {
      // Offline on startup: preserve authenticated status if token exists
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      );
    }
  }

  void setAuthenticated(UserModel user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
    );
  }

  void forceLogout() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
    );
  }
}

final authCoordinatorProvider =
    NotifierProvider<AuthCoordinator, SessionState>(AuthCoordinator.new);
