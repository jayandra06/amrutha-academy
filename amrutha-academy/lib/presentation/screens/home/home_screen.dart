import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/enrollment_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/course_model.dart';
import '../../widgets/course_card.dart';
import '../courses/course_list_screen.dart';
import '../courses/course_detail_screen.dart';
import '../classes/upcoming_classes_screen.dart';
import '../profile/profile_screen.dart';
import '../attendance/attendance_screen.dart';
import '../../../core/config/firebase_config.dart';
import '../../../data/models/user_model.dart';
import '../admin/admin_dashboard_screen.dart';
import '../trainer/trainer_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _enrollmentRepository = EnrollmentRepository();
  final _courseRepository = CourseRepository();
  List<EnrollmentModel> _enrollments = [];
  Map<String, CourseModel> _courseMap = {};
  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadEnrollments();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseConfig.firestore?.collection('users').doc(user.uid).get();
        if (userDoc?.exists ?? false) {
          setState(() {
            _currentUser = UserModel.fromJson({
              'id': user.uid,
              ...userDoc!.data()!,
            });
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final enrollments = await _enrollmentRepository.getMyEnrollments();
      
      // Load course details for each enrollment
      final courseMap = <String, CourseModel>{};
      for (final enrollment in enrollments) {
        final course = await _courseRepository.getCourseById(enrollment.courseId);
        if (course != null) {
          courseMap[enrollment.courseId] = course;
        }
      }

      setState(() {
        _enrollments = enrollments;
        _courseMap = courseMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load enrollments: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is admin or trainer and show appropriate dashboard
    if (_currentUser != null) {
      if (_currentUser!.isAdmin) {
        return const AdminDashboardScreen();
      } else if (_currentUser!.isTrainer) {
        return const TrainerDashboardScreen();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amrutha Academy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
              );
            },
            tooltip: 'Attendance',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEnrollments,
        child: _isLoading
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
                          onPressed: _loadEnrollments,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _enrollments.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUpcomingClassesSection(),
                            const SizedBox(height: 24),
                            _buildMyCoursesSection(),
                            const SizedBox(height: 24),
                            _buildBrowseCoursesSection(),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Courses Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse courses and enroll to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CourseListScreen()),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Courses'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingClassesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Classes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpcomingClassesScreen()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      const Text('No upcoming classes'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyCoursesSection() {
    final activeEnrollments = _enrollments.where((e) => e.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Courses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        activeEnrollments.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active courses',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeEnrollments.length,
                itemBuilder: (context, index) {
                  final enrollment = activeEnrollments[index];
                  final course = _courseMap[enrollment.courseId];
                  if (course == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CourseCard(
                      course: course,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailScreen(courseId: course.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildBrowseCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse Courses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildLevelChip(1),
              const SizedBox(width: 8),
              _buildLevelChip(2),
              const SizedBox(width: 8),
              _buildLevelChip(3),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseListScreen()),
              );
            },
            icon: const Icon(Icons.explore),
            label: const Text('View All Courses'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelChip(int level) {
    return ActionChip(
      label: Text('Level $level'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseListScreen(level: level),
          ),
        );
      },
    );
  }
}
