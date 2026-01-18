import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/enrollment_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/course_model.dart';
import '../../widgets/course_card.dart';
import '../../widgets/app_drawer.dart';
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
  bool _isLoadingUser = true; // Separate flag for user loading
  String? _errorMessage;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    // Load user profile first (required to determine which dashboard to show)
    // Then load enrollments in parallel
    _loadUserProfile().then((_) {
      if (mounted) {
        _loadEnrollments();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingUser = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('🔍 HomeScreen - Loading user profile for UID: ${user.uid}');
        final userDoc = await FirebaseConfig.firestore?.collection('users').doc(user.uid).get();
        if (userDoc?.exists ?? false) {
          final userData = userDoc!.data()!;
          print('🔍 HomeScreen - User data loaded:');
          print('   Role: ${userData['role']}');
          print('   Full data: $userData');
          
          if (!mounted) return;
          final loadedUser = UserModel.fromJson({
            'id': user.uid,
            ...userData,
          });
          
          print('🔍 HomeScreen - Parsed user:');
          print('   Role: ${loadedUser.role}');
          print('   isAdmin: ${loadedUser.isAdmin}');
          print('   isTrainer: ${loadedUser.isTrainer}');
          
          setState(() {
            _currentUser = loadedUser;
            _isLoadingUser = false;
          });
        } else {
          print('⚠️ HomeScreen - User document not found in Firestore');
          print('   Attempting to create user document as fallback...');
          
          // Fallback: Create user document if it doesn't exist
          try {
            final phoneNumber = user.phoneNumber ?? '';
            final userData = {
              'phoneNumber': phoneNumber,
              'fullName': '',
              'email': user.email ?? '',
              'avatar': '',
              'bio': '',
              'birthday': '',
              'location': '',
              'role': 'student', // Default role
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            };
            
            await FirebaseConfig.firestore!
                .collection('users')
                .doc(user.uid)
                .set(userData);
            
            print('✅ HomeScreen - Created user document with default role: student');
            
            // Reload the user data
            final createdUser = UserModel.fromJson({
              'id': user.uid,
              ...userData,
            });
            
            if (!mounted) return;
            setState(() {
              _currentUser = createdUser;
              _isLoadingUser = false;
            });
          } catch (createError) {
            print('❌ HomeScreen - Failed to create user document: $createError');
            if (!mounted) return;
            setState(() {
              _isLoadingUser = false;
            });
          }
        }
      } else {
        print('⚠️ HomeScreen - No current user in Firebase Auth');
        if (!mounted) return;
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('❌ HomeScreen - Error loading user profile: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadEnrollments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final enrollments = await _enrollmentRepository.getMyEnrollments();
      
      // Load course details for each enrollment
      final courseMap = <String, CourseModel>{};
      for (final enrollment in enrollments) {
        if (!mounted) return;
        final course = await _courseRepository.getCourseById(enrollment.courseId);
        if (course != null) {
          courseMap[enrollment.courseId] = course;
        }
      }

      if (!mounted) return;
      setState(() {
        _enrollments = enrollments;
        _courseMap = courseMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load enrollments: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while user profile is being loaded (required to determine dashboard)
    if (_isLoadingUser) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Check if user is admin or trainer and show appropriate dashboard
    if (_currentUser != null) {
      if (_currentUser!.isAdmin) {
        return const AdminDashboardScreen();
      } else if (_currentUser!.isTrainer) {
        return const TrainerDashboardScreen();
      }
    }

    // Default to student home screen
    return Scaffold(
      drawer: AppDrawer(),
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
