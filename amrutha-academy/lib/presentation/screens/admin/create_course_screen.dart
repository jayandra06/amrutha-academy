import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../core/config/firebase_config.dart';
import '../../widgets/app_drawer.dart';

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

  int _selectedLevel = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _classStartTime;
  TimeOfDay? _classEndTime;
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

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _classStartTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _classStartTime = picked;
        // If end time is before start time, clear it
        if (_classEndTime != null && _isTimeBefore(_classEndTime!, picked)) {
          _classEndTime = null;
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    if (_classStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start time first')),
      );
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: _classEndTime ?? TimeOfDay(
        hour: _classStartTime!.hour + 2,
        minute: _classStartTime!.minute,
      ),
    );
    if (picked != null) {
      if (_isTimeBefore(picked, _classStartTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }
      setState(() {
        _classEndTime = picked;
      });
    }
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 < minutes2;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
      if (_classStartTime != null && _classEndTime != null)
        'classTimings': '${_formatTimeOfDay(_classStartTime!)} - ${_formatTimeOfDay(_classEndTime!)}',
      if (_classStartTime != null) 'classStartTime': '${_classStartTime!.hour.toString().padLeft(2, '0')}:${_classStartTime!.minute.toString().padLeft(2, '0')}',
      if (_classEndTime != null) 'classEndTime': '${_classEndTime!.hour.toString().padLeft(2, '0')}:${_classEndTime!.minute.toString().padLeft(2, '0')}',
      'image': '',
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Save directly to Firestore
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
        const SnackBar(content: Text('Course created successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('❌ Firestore save error: $e');
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Failed to create course: $e';
        _isLoading = false;
      });
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
                  ...() {
                    final filteredTrainers = _trainers
                        .where((trainer) => trainer.fullName.isNotEmpty || trainer.phoneNumber.isNotEmpty)
                        .toList();
                    filteredTrainers.sort((a, b) => a.fullName.compareTo(b.fullName));
                    return filteredTrainers.map((trainer) {
                      final displayName = trainer.fullName.isNotEmpty
                          ? trainer.fullName
                          : (trainer.phoneNumber.isNotEmpty ? 'Trainer - ${trainer.phoneNumber}' : 'Trainer');
                      return DropdownMenuItem(
                        value: trainer.id,
                        child: Text(displayName),
                      );
                    });
                  }(),
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
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectStartTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Class Start Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _classStartTime != null
                        ? _formatTimeOfDay(_classStartTime!)
                        : 'Select start time',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectEndTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Class End Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _classEndTime != null
                        ? _formatTimeOfDay(_classEndTime!)
                        : 'Select end time',
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

