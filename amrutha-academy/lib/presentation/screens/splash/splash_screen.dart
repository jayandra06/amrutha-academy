import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // User is logged in - check profile from Firestore directly
        try {
          var userDoc = await FirebaseConfig.firestore
              ?.collection('users')
              .doc(user.uid)
              .get();
          
          // If not found by UID, check by phone number (for admin-created users)
          if ((userDoc?.exists ?? false) == false && user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
            // Normalize phone number for comparison
            String normalizePhone(String phone) {
              return phone.replaceAll(' ', '').replaceAll('-', '');
            }
            
            final normalizedPhone = normalizePhone(user.phoneNumber!);
            
            // Get all users and filter by normalized phone number
            final allUsers = await FirebaseConfig.firestore
                ?.collection('users')
                .get();
            
            if (allUsers != null) {
              for (var doc in allUsers.docs) {
                final userPhone = doc.data()['phoneNumber']?.toString() ?? '';
                if (normalizePhone(userPhone) == normalizedPhone) {
                  final existingData = doc.data();
                  
                  // Update the existing document with the new UID
                  await FirebaseConfig.firestore!
                      .collection('users')
                      .doc(user.uid)
                      .set({
                        ...existingData,
                        'id': user.uid,
                        'phoneNumber': user.phoneNumber ?? '',
                        'updatedAt': DateTime.now().toIso8601String(),
                      }, SetOptions(merge: true));
                  
                  // Delete the old document if it has a different ID
                  if (doc.id != user.uid) {
                    await FirebaseConfig.firestore!
                        .collection('users')
                        .doc(doc.id)
                        .delete();
                  }
                  
                  // Re-fetch the updated document
                  userDoc = await FirebaseConfig.firestore!
                      .collection('users')
                      .doc(user.uid)
                      .get();
                  break;
                }
              }
            }
          }
          
          if (!mounted) return;

          if (userDoc?.exists ?? false) {
            final userData = userDoc!.data()!;
            final fullName = (userData['fullName'] ?? '').toString().trim();
            final existingRole = userData['role']?.toString();
            
            if (fullName.isEmpty) {
              // Profile not complete - redirect to profile completion with existing role
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ProfileCompletionScreen(existingRole: existingRole),
                ),
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


