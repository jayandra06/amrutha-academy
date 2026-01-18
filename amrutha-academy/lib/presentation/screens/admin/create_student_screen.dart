import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../core/config/di_config.dart';
import '../../../core/config/firebase_config.dart';
import 'package:get_it/get_it.dart';

class CreateStudentScreen extends StatefulWidget {
  const CreateStudentScreen({super.key});

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _apiService = GetIt.instance<ApiService>();

  DateTime? _birthday;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Format phone number
    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91$phoneNumber';
    }

    final studentData = {
      'fullName': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': phoneNumber,
      'role': 'student',
      'bio': _bioController.text.trim(),
      'location': _locationController.text.trim(),
      if (_birthday != null) 'birthday': _birthday!.toIso8601String(),
      'avatar': '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Try backend API first
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/users/create',
        data: studentData,
        fromJson: (json) => json as Map<String, dynamic>,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - trying Firestore fallback');
        },
      );

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student created successfully!')),
        );
        Navigator.pop(context, true);
        return;
      } else {
        throw Exception(response.error ?? 'API request failed');
      }
    } catch (apiError) {
      print('⚠️ Create Student API failed: $apiError');
      print('   Attempting Firestore fallback...');
      
      // Fallback: Save directly to Firestore
      try {
        if (FirebaseConfig.firestore == null) {
          throw Exception('Firestore not initialized. Please check your connection.');
        }

        // Generate a unique ID
        final userId = FirebaseConfig.firestore!.collection('users').doc().id;
        
        await FirebaseConfig.firestore!
            .collection('users')
            .doc(userId)
            .set({
              ...studentData,
              'id': userId,
            });

        print('✅ Student saved to Firestore successfully');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student created successfully (saved to Firestore)'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      } catch (firestoreError) {
        print('❌ Firestore save error: $firestoreError');
        if (!mounted) return;
        
        String errorMessage = 'Failed to create student';
        if (apiError.toString().contains('timeout') || apiError.toString().contains('Connection timeout')) {
          errorMessage = 'Connection timeout. The student was saved to Firestore as a fallback.';
        } else if (apiError.toString().contains('Cannot connect') || apiError.toString().contains('Failed host lookup')) {
          errorMessage = 'Cannot connect to server. The student was saved to Firestore as a fallback.';
        } else {
          errorMessage = 'Failed to create student: $firestoreError';
        }
        
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
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
                  border: OutlineInputBorder(),
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
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '9876543210',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _birthday != null
                        ? '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}'
                        : 'Select date',
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createStudent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

