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

  // For Android Emulator: use http://10.0.2.2:3000/api
  // For Physical Device: use your computer's local IP (e.g., http://192.168.1.100:3000/api)
  // To find your IP: Windows: ipconfig, Mac/Linux: ifconfig
  // Make sure your phone and computer are on the same WiFi network
  static AppEnvironment get dev => AppEnvironment(
        environment: Environment.dev,
        apiBaseUrl: 'http://10.0.2.2:3000/api', // Android emulator (change to your local IP for physical device)
        appName: 'Amrutha Academy (Dev)',
      );

  static AppEnvironment get prod => AppEnvironment(
        environment: Environment.prod,
        apiBaseUrl: 'https://your-production-url.com/api',
        appName: 'Amrutha Academy',
      );
}




