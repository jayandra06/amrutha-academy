import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/config/firebase_config.dart';
import '../profile/profile_completion_screen.dart';
import '../main/main_navigation_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      
      // Format phone number with country code if not present
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Default to India +91
      }

      print('📱 Sending OTP to: $formattedPhone');
      
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Phone verification auto-completed');
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Phone verification failed: ${e.code} - ${e.message}');
          String errorMsg = 'Verification failed';
          
          // Provide user-friendly error messages
          switch (e.code) {
            case 'invalid-phone-number':
              errorMsg = 'Invalid phone number format. Please check and try again.';
              break;
            case 'too-many-requests':
              errorMsg = 'Too many requests. Please try again later.';
              break;
            case 'operation-not-allowed':
              errorMsg = 'Phone authentication is not enabled in Firebase Console.';
              break;
            case 'quota-exceeded':
              errorMsg = 'SMS quota exceeded. Please try again later.';
              break;
            case 'missing-phone-number':
              errorMsg = 'Phone number is required.';
              break;
            default:
              errorMsg = e.message ?? 'Failed to send OTP. Error: ${e.code}';
          }
          
          setState(() {
            _errorMessage = errorMsg;
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP code sent successfully. Verification ID received.');
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully! Please check your phone.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto-retrieval timeout. Verification ID: $verificationId');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      
      print('📱 verifyPhoneNumber call completed');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    if (_verificationId == null) {
      setState(() {
        _errorMessage = 'Verification ID not found. Please request OTP again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('Failed to sign in with credential');
      }

      // Get ID token immediately (no artificial delay needed)
      // Use forceRefresh only if token is missing
      String? idToken = await userCredential.user!.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        // Only force refresh if we didn't get a token
        idToken = await userCredential.user!.getIdToken(true);
      }

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to get ID token');
      }

      if (!mounted) return;

      // Check user profile in Firestore
      if (FirebaseConfig.firestore == null) {
        throw Exception('Firestore not initialized');
      }

      final phoneNumber = userCredential.user!.phoneNumber ?? '';
      
      // Normalize phone number for comparison (remove spaces, dashes, ensure consistent format)
      String normalizePhone(String phone) {
        if (phone.isEmpty) return '';
        // Remove all spaces, dashes, parentheses
        String normalized = phone.replaceAll(' ', '').replaceAll('-', '').replaceAll('(', '').replaceAll(')', '');
        // If it starts with 91 but no +, add +
        if (normalized.startsWith('91') && !normalized.startsWith('+91') && normalized.length >= 10) {
          normalized = '+$normalized';
        }
        // If it doesn't start with + and has 10 digits, assume +91
        if (!normalized.startsWith('+') && normalized.length == 10 && RegExp(r'^\d{10}$').hasMatch(normalized)) {
          normalized = '+91$normalized';
        }
        return normalized.toLowerCase();
      }
      
      print('🔍 Phone Auth: Looking for user with phone: $phoneNumber');
      
      // First, check if user document exists by UID (for existing Firebase Auth users)
      var userDoc = await FirebaseConfig.firestore!
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // If not found by UID, check by phone number (for admin-created users)
      String? existingRole;
      if (!userDoc.exists && phoneNumber.isNotEmpty) {
        final normalizedPhone = normalizePhone(phoneNumber);
        
        // Get all users and filter by normalized phone number
        final allUsers = await FirebaseConfig.firestore!
            .collection('users')
            .get();
        
        // Find matching user by phone number
        print('🔍 Searching ${allUsers.docs.length} users for phone: $normalizedPhone');
        for (var doc in allUsers.docs) {
          final userPhone = doc.data()['phoneNumber']?.toString() ?? '';
          final normalizedUserPhone = normalizePhone(userPhone);
          print('   Comparing: "$normalizedUserPhone" == "$normalizedPhone"? ${normalizedUserPhone == normalizedPhone}');
          
          if (normalizedUserPhone == normalizedPhone) {
            final existingData = doc.data();
            
            // Get existing role and fullName BEFORE migrating
            existingRole = existingData['role']?.toString();
            final existingFullName = (existingData['fullName'] ?? '').toString().trim();
            
            print('✅ Found existing user: ID=${doc.id}, Role=$existingRole, FullName=$existingFullName');
            
            // Update the existing document with the new UID
            await FirebaseConfig.firestore!
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
                  ...existingData,
                  'id': userCredential.user!.uid,
                  'phoneNumber': phoneNumber,
                  'updatedAt': DateTime.now().toIso8601String(),
                }, SetOptions(merge: true));
            
            // Delete the old document if it has a different ID
            if (doc.id != userCredential.user!.uid) {
              await FirebaseConfig.firestore!
                  .collection('users')
                  .doc(doc.id)
                  .delete();
            }
            
            // Re-fetch the updated document
            userDoc = await FirebaseConfig.firestore!
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();
            
            // If existing user already has fullName, use that for navigation decision
            if (existingFullName.isNotEmpty && !mounted) return;
            if (existingFullName.isNotEmpty) {
              // Profile already complete - go directly to main screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
              return;
            }
            break;
          }
        }
      }

      // Check if profile is complete (fullName must not be null or empty)
      String fullName = '';
      if (userDoc.exists) {
        final userData = userDoc.data();
        fullName = (userData?['fullName'] ?? '').toString().trim();
        existingRole = existingRole ?? userData?['role']?.toString();
        print('📋 User document exists: FullName=$fullName, Role=$existingRole');
      } else {
        print('📋 No user document found - new user, will create account in profile completion');
      }

      if (!mounted) return;

      if (fullName.isEmpty) {
        // Profile not complete or new user - redirect to profile completion
        // Pass the existing role if found (for admin-created users), otherwise null (new user = student)
        print('🔄 Redirecting to Profile Completion (existingRole=$existingRole)');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProfileCompletionScreen(existingRole: existingRole),
          ),
        );
      } else {
        // Profile complete - go to main navigation screen
        print('✅ Profile complete, redirecting to Main Navigation');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Authentication failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Sign In with Phone',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to receive OTP',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!_otpSent) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+91 9876543210',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send OTP'),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.lock),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.length != 6) {
                        return 'Please enter 6-digit OTP';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify OTP'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _otpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: const Text('Change Phone Number'),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
