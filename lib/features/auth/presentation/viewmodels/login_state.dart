class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      LoginState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}
