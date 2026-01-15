import 'package:flutter/material.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/models/course_model.dart';
import '../../widgets/course_card.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  final int? level;

  const CourseListScreen({super.key, this.level});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _courseRepository = CourseRepository();
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedLevel = 1;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.level ?? 1;
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courses = await _courseRepository.getCoursesByLevel(_selectedLevel);
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load courses: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Courses'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Level 1')),
                      ButtonSegment(value: 2, label: Text('Level 2')),
                      ButtonSegment(value: 3, label: Text('Level 3')),
                    ],
                    selected: {_selectedLevel},
                    onSelectionChanged: (Set<int> selected) {
                      setState(() {
                        _selectedLevel = selected.first;
                      });
                      _loadCourses();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
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
                              onPressed: _loadCourses,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _courses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses found',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try selecting a different level',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCourses,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _courses.length,
                              itemBuilder: (context, index) {
                                final course = _courses[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
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
                          ),
          ),
        ],
      ),
    );
  }
}




