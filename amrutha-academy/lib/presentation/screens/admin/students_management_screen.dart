import 'package:flutter/material.dart';
import '../../../core/config/firebase_config.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/enrollment_repository.dart';
import '../../widgets/app_drawer.dart';
import 'create_student_screen.dart';

class StudentsManagementScreen extends StatefulWidget {
  const StudentsManagementScreen({super.key});

  @override
  State<StudentsManagementScreen> createState() => _StudentsManagementScreenState();
}

class _StudentsManagementScreenState extends State<StudentsManagementScreen> {
  final _searchController = TextEditingController();
  final _courseRepository = CourseRepository();
  final _enrollmentRepository = EnrollmentRepository();
  
  List<UserModel> _allStudents = [];
  List<UserModel> _filteredStudents = [];
  List<CourseModel> _courses = [];
  Map<String, CourseModel> _courseMap = {};
  Map<String, List<EnrollmentModel>> _studentEnrollments = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedLevel;
  String? _selectedCourseId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load students
      final usersSnapshot = await FirebaseConfig.firestore
          ?.collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      if (usersSnapshot != null) {
        final students = usersSnapshot.docs
            .map((doc) => UserModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();

        // Load courses for filtering
        final courses = await _courseRepository.getAllCourses();
        final courseMap = <String, CourseModel>{};
        for (var course in courses) {
          courseMap[course.id] = course;
        }

        // Load enrollments to get student-course relationships
        final enrollmentsMap = <String, List<EnrollmentModel>>{};
        for (var student in students) {
          try {
            final enrollments = await _enrollmentRepository.getEnrollmentsByUserId(student.id);
            enrollmentsMap[student.id] = enrollments;
          } catch (e) {
            enrollmentsMap[student.id] = [];
          }
        }

        setState(() {
          _allStudents = students;
          _courses = courses;
          _courseMap = courseMap;
          _studentEnrollments = enrollmentsMap;
          _isLoading = false;
        });
        _applyFilters();
      } else {
        setState(() {
          _allStudents = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load students: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<UserModel> filtered = List.from(_allStudents);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((student) {
        final nameMatch = student.fullName.toLowerCase().contains(_searchQuery);
        final phoneMatch = student.phoneNumber.contains(_searchQuery);
        final emailMatch = student.email.toLowerCase().contains(_searchQuery);
        return nameMatch || phoneMatch || emailMatch;
      }).toList();
    }

    // Apply level filter
    if (_selectedLevel != null) {
      filtered = filtered.where((student) {
        final enrollments = _studentEnrollments[student.id] ?? [];
        return enrollments.any((enrollment) {
          final course = _courseMap[enrollment.courseId];
          return course != null && course.level.toString() == _selectedLevel;
        });
      }).toList();
    }

    // Apply course filter
    if (_selectedCourseId != null && _selectedCourseId!.isNotEmpty) {
      filtered = filtered.where((student) {
        final enrollments = _studentEnrollments[student.id] ?? [];
        return enrollments.any((enrollment) => enrollment.courseId == _selectedCourseId);
      }).toList();
    }

    setState(() {
      _filteredStudents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Students Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateStudentScreen()),
              );
              if (result == true) {
                _loadData();
              }
            },
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or email',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Level',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Levels')),
                          const DropdownMenuItem(value: '1', child: Text('Level 1')),
                          const DropdownMenuItem(value: '2', child: Text('Level 2')),
                          const DropdownMenuItem(value: '3', child: Text('Level 3')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCourseId,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Course',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Courses')),
                          ..._courses.map((course) => DropdownMenuItem(
                                value: course.id,
                                child: Text(
                                  course.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCourseId = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredStudents.length} student${_filteredStudents.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_selectedLevel != null || _selectedCourseId != null || _searchQuery.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedLevel = null;
                        _selectedCourseId = null;
                        _searchController.clear();
                      });
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),
          // Students list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
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
                                onPressed: _loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredStudents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty || _selectedLevel != null || _selectedCourseId != null
                                        ? 'No students match the filters'
                                        : 'No students found',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columnSpacing: 24,
                                  headingRowColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.surfaceVariant,
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Name',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Phone Number',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Email ID',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Course Name',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  rows: _filteredStudents.map((student) {
                                    final enrollments = _studentEnrollments[student.id] ?? [];
                                    final enrolledCourses = enrollments
                                        .map((e) => _courseMap[e.courseId])
                                        .whereType<CourseModel>()
                                        .toList();
                                    
                                    // Get course names (comma-separated if multiple)
                                    final courseNames = enrolledCourses
                                        .map((course) => course.title)
                                        .join(', ');
                                    final courseNameDisplay = courseNames.isEmpty ? '-' : courseNames;

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            student.fullName.isNotEmpty ? student.fullName : '-',
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          onTap: () {
                                            // TODO: Navigate to student details screen
                                          },
                                        ),
                                        DataCell(
                                          Text(
                                            student.phoneNumber.isNotEmpty ? student.phoneNumber : '-',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            student.email.isNotEmpty ? student.email : '-',
                                          ),
                                        ),
                                        DataCell(
                                          Text(courseNameDisplay),
                                        ),
                                      ],
                                    );
                                  }).toList() as List<DataRow>,
                                ),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
