import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/login_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../controllers/auth_coordinator.dart';
import 'login_state.dart';

/// Screen-scoped ViewModel for the Login screen.
/// Pure Dart: receives credentials as plain strings, owns no widgets or controllers.
class LoginViewModel extends AutoDisposeNotifier<LoginState> {
  IAuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  LoginState build() => const LoginState();

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(
        LoginRequest(email: email, password: password),
      );
      ref.read(authCoordinatorProvider.notifier).setAuthenticated(user);
      state = state.copyWith(isLoading: false);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, errorMessage: f.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.genericError,
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final loginViewModelProvider =
    AutoDisposeNotifierProvider<LoginViewModel, LoginState>(
  LoginViewModel.new,
);
