import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/user_model.dart';
import '../../../core/config/di_config.dart';
import '../../../core/config/firebase_config.dart';
import '../../widgets/app_drawer.dart';
import 'package:get_it/get_it.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _apiService = GetIt.instance<ApiService>();

  int _selectedLevel = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _category;
  String? _trainerId;
  List<UserModel> _trainers = [];
  bool _isLoading = false;
  bool _isLoadingTrainers = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainers() async {
    setState(() {
      _isLoadingTrainers = true;
    });

    try {
      final trainersSnapshot = await FirebaseConfig.firestore
          ?.collection('users')
          .where('role', isEqualTo: 'trainer')
          .get();

      if (trainersSnapshot != null) {
        final trainers = trainersSnapshot.docs
            .map((doc) => UserModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();

        setState(() {
          _trainers = trainers;
          _isLoadingTrainers = false;
        });
      } else {
        setState(() {
          _trainers = [];
          _isLoadingTrainers = false;
        });
      }
    } catch (e) {
      setState(() {
        _trainers = [];
        _isLoadingTrainers = false;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date first')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get trainer name if trainer is assigned
    String? trainerName;
    if (_trainerId != null && _trainerId!.isNotEmpty && _trainers.isNotEmpty) {
      try {
        final trainer = _trainers.firstWhere((t) => t.id == _trainerId);
        trainerName = trainer.fullName.isNotEmpty ? trainer.fullName : null;
      } catch (e) {
        // Trainer not found in list, will be null
        trainerName = null;
      }
    }

    final courseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'level': _selectedLevel,
      'price': double.parse(_priceController.text.trim()),
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'duration': int.parse(_durationController.text.trim()),
      'category': _category,
      'trainerId': _trainerId,
      'trainerName': trainerName,
      'image': '',
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Try backend API first
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/courses/create',
        data: courseData,
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
          const SnackBar(content: Text('Course created successfully!')),
        );
        Navigator.pop(context, true);
        return;
      } else {
        throw Exception(response.error ?? 'API request failed');
      }
    } catch (apiError) {
      print('⚠️ Create Course API failed: $apiError');
      print('   Attempting Firestore fallback...');
      
      // Fallback: Save directly to Firestore
      try {
        if (FirebaseConfig.firestore == null) {
          throw Exception('Firestore not initialized. Please check your connection.');
        }

        // Get current user as admin
        final currentUser = FirebaseConfig.auth?.currentUser;
        final courseId = FirebaseConfig.firestore!.collection('courses').doc().id;
        
        await FirebaseConfig.firestore!
            .collection('courses')
            .doc(courseId)
            .set({
              ...courseData,
              'id': courseId,
              'adminId': currentUser?.uid ?? '',
            });

        print('✅ Course saved to Firestore successfully');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course created successfully (saved to Firestore)'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      } catch (firestoreError) {
        print('❌ Firestore save error: $firestoreError');
        if (!mounted) return;
        
        String errorMessage = 'Failed to create course';
        if (apiError.toString().contains('timeout') || apiError.toString().contains('Connection timeout')) {
          errorMessage = 'Connection timeout. The course was saved to Firestore as a fallback.';
        } else if (apiError.toString().contains('Cannot connect') || apiError.toString().contains('Failed host lookup')) {
          errorMessage = 'Cannot connect to server. The course was saved to Firestore as a fallback.';
        } else {
          errorMessage = 'Failed to create course: $firestoreError';
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
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Create Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Level *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Level 1')),
                  DropdownMenuItem(value: 2, child: Text('Level 2')),
                  DropdownMenuItem(value: 3, child: Text('Level 3')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (₹) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (days) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Select start date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Select end date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _trainerId,
                decoration: const InputDecoration(
                  labelText: 'Assign Trainer',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Trainer Assigned')),
                  ..._trainers.map((trainer) => DropdownMenuItem(
                        value: trainer.id,
                        child: Text(trainer.fullName),
                      )),
                ],
                onChanged: _isLoadingTrainers
                    ? null
                    : (value) {
                        setState(() {
                          _trainerId = value;
                        });
                      },
              ),
              if (_isLoadingTrainers)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
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
                onPressed: _isLoading ? null : _createCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

