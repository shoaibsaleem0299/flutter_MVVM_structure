/// Pass at build time: flutter run --dart-define=API_BASE_URL=https://...
class Env {
  const Env._();
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '[URL]/api',
  );
}
