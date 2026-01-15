import 'package:flutter/material.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/enrollment_repository.dart';
import '../../../data/models/course_model.dart';
import '../payments/payment_screen.dart';
import '../classes/upcoming_classes_screen.dart';
import '../chat/chat_room_screen.dart';
import '../../../data/repositories/chat_repository.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _courseRepository = CourseRepository();
  final _enrollmentRepository = EnrollmentRepository();
  CourseModel? _course;
  bool _isLoading = true;
  bool _isEnrolled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
    _checkEnrollment();
  }

  Future<void> _loadCourseDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final course = await _courseRepository.getCourseById(widget.courseId);
      setState(() {
        _course = course;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load course: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkEnrollment() async {
    try {
      final enrollments = await _enrollmentRepository.getMyEnrollments();
      setState(() {
        _isEnrolled = enrollments.any((e) => e.courseId == widget.courseId && e.isActive);
      });
    } catch (e) {
      // Ignore enrollment check errors
    }
  }

  Future<void> _handleEnroll() async {
    if (_course == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          course: _course!,
          onPaymentSuccess: () {
            _checkEnrollment();
            Navigator.pop(context); // Go back to course detail
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enrolled successfully!')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
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
                        onPressed: _loadCourseDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _course == null
                  ? const Center(child: Text('Course not found'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Course Image
                          if (_course!.image != null && _course!.image!.isNotEmpty)
                            Image.network(
                              _course!.image!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          // Course Info
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Level ${_course!.level}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '₹${_course!.price.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _course!.title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (_course!.trainerName != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Trainer: ${_course!.trainerName}',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildInfoChip(Icons.calendar_today, '${_course!.duration} days'),
                                    const SizedBox(width: 12),
                                    _buildInfoChip(
                                      Icons.access_time,
                                      _formatDateRange(_course!.startDate, _course!.endDate),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'About',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _course!.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: _course != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isEnrolled
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UpcomingClassesScreen(courseId: _course!.id),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.class_),
                              label: const Text('View Classes'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.chat),
                              label: const Text('Chat Room'),
                              onPressed: () async {
                                try {
                                  // Get enrollment to find chat room
                                  final enrollments = await _enrollmentRepository.getMyEnrollments();
                                  final enrollment = enrollments.firstWhere(
                                    (e) => e.courseId == _course!.id && e.isActive,
                                  );
                                  if (enrollment.chatRoomId != null) {
                                    // Fetch chat room details and navigate
                                    final chatRepo = ChatRepository();
                                    final chatRoom = await chatRepo.getChatRoomById(enrollment.chatRoomId!);
                                    if (chatRoom != null && mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatRoomScreen(chatRoom: chatRoom),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Chat room not found')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Chat room not available')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: _handleEnroll,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Enroll Now'),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDateRange(dynamic startDate, dynamic endDate) {
    try {
      DateTime start, end;
      if (startDate is String) {
        start = DateTime.parse(startDate);
      } else if (startDate is DateTime) {
        start = startDate;
      } else {
        return 'Dates TBA';
      }
      
      if (endDate is String) {
        end = DateTime.parse(endDate);
      } else if (endDate is DateTime) {
        end = endDate;
      } else {
        return 'Dates TBA';
      }
      
      return '${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';
    } catch (e) {
      return 'Dates TBA';
    }
  }
}

