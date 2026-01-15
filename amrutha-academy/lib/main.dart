import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/firebase_config.dart';
import 'core/config/environment.dart';
import 'core/config/di_config.dart';
import 'services/notification_service.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  try {
    await FirebaseConfig.initialize();
  } catch (e) {
    print('Fatal: Firebase initialization failed: $e');
    // App won't work without Firebase, but let it run to show error
  }

  // Setup dependency injection FIRST (before NotificationService needs it)
  final env = AppEnvironment.dev;
  await setupDependencies(env);

  // Initialize notifications (non-critical, can fail silently)
  // Now ApiService is available in GetIt
  try {
    await NotificationService().initialize();
  } catch (e) {
    print('Warning: Notification service initialization failed: $e');
  }

  runApp(MyApp(environment: env));
}

class MyApp extends StatelessWidget {
  final AppEnvironment environment;

  const MyApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: environment.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
