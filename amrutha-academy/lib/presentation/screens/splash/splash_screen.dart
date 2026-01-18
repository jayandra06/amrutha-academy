import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/firebase_config.dart';
import '../auth/phone_auth_screen.dart';
import '../main/main_navigation_screen.dart';
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
    // Remove artificial delay - check immediately
    // Only add minimal delay for smooth UI transition (100ms)
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (!mounted) return;
      
      if (user != null) {
        // User is logged in - check profile from Firestore directly (faster than API call)
        try {
          final userDoc = await FirebaseConfig.firestore
              ?.collection('users')
              .doc(user.uid)
              .get();
          
          if (!mounted) return;

          if (userDoc?.exists ?? false) {
            final userData = userDoc!.data()!;
            final fullName = (userData['fullName'] ?? '').toString().trim();
            
            if (fullName.isEmpty) {
              // Profile not complete - redirect to profile completion
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
              );
            } else {
              // Profile complete - go to main navigation screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
            }
          } else {
            // User document doesn't exist - redirect to profile completion
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
            );
          }
        } catch (e) {
          print('Error checking user profile: $e');
          // On error, go to main navigation screen and let it handle the state
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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


