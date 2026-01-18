import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/firebase_config.dart';
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

  // Initialize notifications (non-critical, can fail silently)
  try {
    await NotificationService().initialize();
  } catch (e) {
    print('Warning: Notification service initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amrutha Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
