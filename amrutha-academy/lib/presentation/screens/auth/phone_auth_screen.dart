import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../../core/config/firebase_config.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/user_model.dart';
import 'package:get_it/get_it.dart';
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

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorMessage = e.message ?? 'Verification failed';
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
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

      // Verify with backend - manually set the Authorization header since user might not be in FirebaseConfig.auth yet
      final apiService = GetIt.instance<ApiService>();
      final dio = GetIt.instance<Dio>();
      
      // Temporarily set the auth header
      final originalHeaders = Map<String, dynamic>.from(dio.options.headers);
      dio.options.headers['Authorization'] = 'Bearer $idToken';

      try {
        // Don't send role preference - backend will use existing user role from database
        final response = await apiService.post<UserModel>(
          '/auth/phone/verify-id-token',
          data: {},
          fromJson: (json) => UserModel.fromJson(json),
        );

        if (!mounted) return;

        if (response.isSuccess && response.data != null) {
          final user = response.data!;
          
          // Check if profile is complete (fullName must not be null or empty)
          final fullName = user.fullName.trim();
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
          if (!mounted) return;
          setState(() {
            _errorMessage = response.error ?? 'Authentication failed';
            _isLoading = false;
          });
        }
      } finally {
        // Restore original headers
        dio.options.headers.clear();
        dio.options.headers.addAll(originalHeaders);
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Authentication failed';
      if (e.toString().contains('timeout') || e.toString().contains('Connection timeout')) {
        errorMessage = 'Connection timeout. Please check:\n1. Backend server is running\n2. Correct API URL configured\n3. Device and server are on same network';
      } else if (e.toString().contains('Failed host lookup') || e.toString().contains('Cannot connect')) {
        errorMessage = 'Cannot connect to server. Make sure the backend is running. For physical devices, use your computer\'s IP address instead of localhost.';
      } else {
        errorMessage = 'Authentication failed: $e';
      }
      setState(() {
        _errorMessage = errorMessage;
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
