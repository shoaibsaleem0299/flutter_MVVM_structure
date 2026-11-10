import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/home_repository.dart';
import '../../domain/repositories/i_home_repository.dart';
import 'home_state.dart';

/// Screen-scoped ViewModel for the Dashboard / Home screen.
/// Pure MVVM: Zero imports from Flutter widgets or the Auth feature.
class HomeViewModel extends AutoDisposeNotifier<HomeState> {
  IHomeRepository get _repo => ref.read(homeRepositoryProvider);
  CancelToken? _cancelToken;

  @override
  HomeState build() {
    _cancelToken = CancelToken();
    ref.onDispose(() {
      _cancelToken?.cancel();
    });

    Future.microtask(() => loadDashboard());
    return const HomeState(isLoading: true);
  }

  Future<void> loadDashboard({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final profile = await _repo.getDashboardProfile(
        cancelToken: _cancelToken,
      );
      state = state.copyWith(
        isLoading: false,
        profile: profile,
      );
    } on CanceledFailure {
      // Ignored on screen unmount
    } on Failure catch (f) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.genericError,
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final homeViewModelProvider =
    AutoDisposeNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
