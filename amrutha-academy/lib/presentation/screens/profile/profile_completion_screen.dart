import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/config/firebase_config.dart';
import '../../../data/models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../core/config/di_config.dart';
import 'package:get_it/get_it.dart';
import '../home/home_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _birthday;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final profileData = {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        if (_birthday != null) 'birthday': _birthday!.toIso8601String(),
        'role': 'student',
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Try backend API first
      try {
        final apiService = GetIt.instance<ApiService>();
        final response = await apiService.put<UserModel>(
          '/profile',
          data: profileData,
          fromJson: (json) => UserModel.fromJson(json),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Request timeout - trying Firestore fallback');
          },
        );

        if (!mounted) return;

        if (response.isSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        } else {
          throw Exception(response.error ?? 'API request failed');
        }
      } catch (apiError) {
        print('⚠️ Profile update API failed: $apiError');
        print('   Attempting Firestore fallback...');
        
        // Fallback: Save directly to Firestore
        if (FirebaseConfig.firestore == null) {
          throw Exception('Firestore not initialized. Please check your connection.');
        }

        // Ensure user document exists first
        final userDoc = await FirebaseConfig.firestore!
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = {
          'phoneNumber': user.phoneNumber ?? '',
          'fullName': profileData['fullName'],
          'email': profileData['email'],
          'bio': profileData['bio'],
          'location': profileData['location'],
          'birthday': profileData['birthday'] ?? '',
          'role': profileData['role'],
          'avatar': userDoc.exists ? (userDoc.data()?['avatar'] ?? '') : '',
          'updatedAt': DateTime.now().toIso8601String(),
          if (!userDoc.exists) 'createdAt': DateTime.now().toIso8601String(),
        };

        await FirebaseConfig.firestore!
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

        print('✅ Profile saved to Firestore successfully');

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      print('❌ Profile save error: $e');
      if (!mounted) return;
      
      String errorMessage = 'Failed to save profile';
      if (e.toString().contains('timeout') || e.toString().contains('Connection timeout')) {
        errorMessage = 'Connection timeout. Please check:\n1. Backend server is running\n2. Correct API URL configured\n3. Device and server are on same network';
      } else if (e.toString().contains('Cannot connect') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot connect to server. The profile was saved to Firestore as a fallback.';
      } else {
        errorMessage = 'Failed to save profile: $e';
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
        title: const Text('Complete Your Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete Your Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Birthday',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _birthday != null
                          ? '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}'
                          : 'Select date',
                      style: TextStyle(
                        color: _birthday != null
                            ? null
                            : Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

