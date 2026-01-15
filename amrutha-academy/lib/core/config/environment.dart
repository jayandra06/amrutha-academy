enum Environment { dev, prod }

class AppEnvironment {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;

  AppEnvironment({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
  });

  static AppEnvironment get dev => AppEnvironment(
        environment: Environment.dev,
        apiBaseUrl: 'http://10.0.2.2:3000/api', // Android emulator
        appName: 'Amrutha Academy (Dev)',
      );

  static AppEnvironment get prod => AppEnvironment(
        environment: Environment.prod,
        apiBaseUrl: 'https://your-production-url.com/api',
        appName: 'Amrutha Academy',
      );
}




