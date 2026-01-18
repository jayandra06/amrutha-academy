import 'package:flutter/material.dart';
import '../../../core/config/firebase_config.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';

class TrainerDetailScreen extends StatefulWidget {
  final String trainerId;

  const TrainerDetailScreen({super.key, required this.trainerId});

  @override
  State<TrainerDetailScreen> createState() => _TrainerDetailScreenState();
}

class _TrainerDetailScreenState extends State<TrainerDetailScreen> {
  final _courseRepository = CourseRepository();
  UserModel? _trainer;
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrainerDetails();
  }

  Future<void> _loadTrainerDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load trainer data
      final trainerDoc = await FirebaseConfig.firestore
          ?.collection('users')
          .doc(widget.trainerId)
          .get();

      if (trainerDoc != null && trainerDoc.exists) {
        final trainer = UserModel.fromJson({
          'id': trainerDoc.id,
          ...trainerDoc.data()!,
        });

        // Load courses assigned to this trainer
        final allCourses = await _courseRepository.getAllCourses();
        final trainerCourses = allCourses
            .where((course) => course.trainerId == trainer.id)
            .toList();

        setState(() {
          _trainer = trainer;
          _courses = trainerCourses;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Trainer not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load trainer details: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not specified';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTrainerDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _trainer == null
                  ? const Center(child: Text('Trainer not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  backgroundImage: _trainer!.avatar != null && _trainer!.avatar!.isNotEmpty
                                      ? NetworkImage(_trainer!.avatar!)
                                      : null,
                                  child: _trainer!.avatar == null || _trainer!.avatar!.isEmpty
                                      ? Text(
                                          _trainer!.fullName.isNotEmpty
                                              ? _trainer!.fullName[0].toUpperCase()
                                              : 'T',
                                          style: TextStyle(
                                            fontSize: 40,
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _trainer!.fullName,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (_trainer!.role == 'trainer')
                                  Chip(
                                    label: const Text('Trainer'),
                                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Personal Information
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.phone, 'Phone Number', _trainer!.phoneNumber),
                          if (_trainer!.email.isNotEmpty)
                            _buildDetailRow(Icons.email, 'Email', _trainer!.email),
                          if (_trainer!.location != null && _trainer!.location!.isNotEmpty)
                            _buildDetailRow(Icons.location_on, 'Location', _trainer!.location!),
                          if (_trainer!.birthday != null)
                            _buildDetailRow(Icons.calendar_today, 'Birthday', _formatDate(_trainer!.birthday)),
                          if (_trainer!.bio != null && _trainer!.bio!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Bio',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _trainer!.bio!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Assigned Courses
                          Text(
                            'Assigned Courses (${_courses.length})',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          if (_courses.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('No courses assigned'),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _courses.length,
                              itemBuilder: (context, index) {
                                final course = _courses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      child: Text(
                                        'L${course.level}',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      course.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Price: ₹${course.price.toStringAsFixed(2)}'),
                                        Text('Duration: ${course.duration} days'),
                                        Text(
                                          '${_formatDate(course.startDate)} - ${_formatDate(course.endDate)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
