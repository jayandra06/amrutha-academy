import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/user_model.dart';
import '../../../core/config/di_config.dart';
import 'package:get_it/get_it.dart';
import '../auth/phone_auth_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_completion_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (!mounted) return;
      
      if (user != null) {
        // User is logged in - check profile completion
        try {
          final apiService = GetIt.instance<ApiService>();
          final response = await apiService.get<UserModel>(
            '/profile',
            fromJson: (json) => UserModel.fromJson(json),
          );

          if (!mounted) return;

          if (response.isSuccess && response.data != null) {
            final userProfile = response.data!;
            final fullName = userProfile.fullName.trim();
            
            if (fullName.isEmpty) {
              // Profile not complete - redirect to profile completion
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
              );
            } else {
              // Profile complete - go to home screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          } else {
            // If profile fetch fails, assume incomplete and redirect to profile completion
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
            );
          }
        } catch (e) {
          print('Error fetching user profile: $e');
          // On error, go to home screen and let it handle the state
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      } else {
        // Not logged in - go to auth screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
        );
      }
    } catch (e) {
      print('Error checking auth state: $e');
      // If Firebase fails, still try to navigate to auth screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Amrutha Academy',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


