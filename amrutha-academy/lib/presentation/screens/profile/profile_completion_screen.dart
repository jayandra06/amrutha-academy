import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/config/firebase_config.dart';
import '../home/home_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String? existingRole;
  
  const ProfileCompletionScreen({super.key, this.existingRole});

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

      // Save directly to Firestore
      if (FirebaseConfig.firestore == null) {
        throw Exception('Firestore not initialized. Please check your connection.');
      }

      final phoneNumber = user.phoneNumber ?? '';
      
      // Normalize phone number for comparison (same logic as phone_auth_screen)
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
      
      print('🔍 Profile Completion: Looking for existing user with phone: $phoneNumber');
      
      // First check by UID
      var userDoc = await FirebaseConfig.firestore!
          .collection('users')
          .doc(user.uid)
          .get();
      
      String? roleToUse;
      String? avatarValue;
      String? createdAtValue;
      
      // If not found by UID, check by phone number to find existing user
      if (!userDoc.exists && phoneNumber.isNotEmpty) {
        final normalizedPhone = normalizePhone(phoneNumber);
        final allUsers = await FirebaseConfig.firestore!
            .collection('users')
            .get();
        
        for (var doc in allUsers.docs) {
          final userPhone = doc.data()['phoneNumber']?.toString() ?? '';
          if (normalizePhone(userPhone) == normalizedPhone) {
            // Found existing user with this phone number
            final existingData = doc.data();
            roleToUse = existingData['role']?.toString() ?? 'student';
            avatarValue = existingData['avatar']?.toString() ?? '';
            createdAtValue = existingData['createdAt']?.toString();
            
            // Delete the old document if it has a different ID
            if (doc.id != user.uid) {
              await FirebaseConfig.firestore!
                  .collection('users')
                  .doc(doc.id)
                  .delete();
            }
            break;
          }
        }
      }
      
      // Get role from existing document or use passed role or default
      roleToUse = roleToUse ?? 
                  widget.existingRole ?? 
                  (userDoc.exists ? (userDoc.data()?['role']?.toString()) : null) ?? 
                  'student';
      
      avatarValue = avatarValue ?? (userDoc.exists ? (userDoc.data()?['avatar'] ?? '') : '');
      createdAtValue = createdAtValue ?? (userDoc.exists ? (userDoc.data()?['createdAt']?.toString()) : null) ?? DateTime.now().toIso8601String();

      final userData = {
        'id': user.uid,
        'phoneNumber': phoneNumber,
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'birthday': _birthday != null ? _birthday!.toIso8601String() : '',
        'role': roleToUse, // Preserve existing role
        'avatar': avatarValue,
        'updatedAt': DateTime.now().toIso8601String(),
        'createdAt': createdAtValue,
      };

      // Always save to the Firebase Auth UID (this ensures one phone = one document)
      await FirebaseConfig.firestore!
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      print('✅ Profile saved to Firestore successfully');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      print('❌ Profile save error: $e');
      if (!mounted) return;
      
      String errorMessage = 'Failed to save profile: $e';
      
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

