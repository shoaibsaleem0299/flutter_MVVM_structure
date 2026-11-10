import '../../data/models/dashboard_profile_model.dart';

class HomeState {
  const HomeState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
  });

  final bool isLoading;
  final DashboardProfileModel? profile;
  final String? errorMessage;

  HomeState copyWith({
    bool? isLoading,
    DashboardProfileModel? profile,
    String? errorMessage,
    bool clearError = false,
  }) =>
      HomeState(
        isLoading: isLoading ?? this.isLoading,
        profile: profile ?? this.profile,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}
