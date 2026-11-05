import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/login_request.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// All auth logic lives here: form key, text controllers, validation trigger,
/// login / logout / session restore. Pages only render and call these methods.
class AuthViewModel extends Notifier<AuthState> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
    });
    Future.microtask(restoreSession);
    return const AuthState();
  }

  Future<void> restoreSession() async {
    final user = await _repo.restoreSession();
    state = state.copyWith(
      status: user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated,
      user: user,
    );
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(
        LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
      passwordController.clear();
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: user,
      );
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, errorMessage: f.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emailController.clear();
    passwordController.clear();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearError: true,
    );
  }

  /// Call after the UI has shown the error so it is not shown twice.
  void clearError() => state = state.copyWith(clearError: true);
}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
