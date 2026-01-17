import 'package:flutter/material.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/models/course_model.dart';
import '../../widgets/course_card.dart';
import '../../widgets/app_drawer.dart';
import 'course_detail_screen.dart';

class BrowseCoursesScreen extends StatefulWidget {
  const BrowseCoursesScreen({super.key});

  @override
  State<BrowseCoursesScreen> createState() => _BrowseCoursesScreenState();
}

class _BrowseCoursesScreenState extends State<BrowseCoursesScreen> {
  final _courseRepository = CourseRepository();
  final _searchController = TextEditingController();
  List<CourseModel> _allCourses = [];
  List<CourseModel> _filteredCourses = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedLevel;
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadAllCourses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  Future<void> _loadAllCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load courses for all levels
      List<CourseModel> allCourses = [];
      
      // Load courses for each level (1, 2, 3)
      for (int level = 1; level <= 3; level++) {
        try {
          final courses = await _courseRepository.getCoursesByLevel(level);
          allCourses.addAll(courses);
        } catch (e) {
          print('Error loading courses for level $level: $e');
        }
      }

      setState(() {
        _allCourses = allCourses;
        _filteredCourses = allCourses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load courses: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        // Filter by level
        if (_selectedLevel != null && course.level != _selectedLevel) {
          return false;
        }

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          final titleMatch = course.title.toLowerCase().contains(_searchQuery);
          final descriptionMatch = course.description.toLowerCase().contains(_searchQuery);
          final categoryMatch = course.category?.toLowerCase().contains(_searchQuery) ?? false;
          
          if (!titleMatch && !descriptionMatch && !categoryMatch) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _onLevelChanged(int? level) {
    setState(() {
      _selectedLevel = level;
      _applyFilters();
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Courses'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
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
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),

          // Level Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    isSelected: _selectedLevel == null,
                    onTap: () => _onLevelChanged(null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Level 1',
                    isSelected: _selectedLevel == 1,
                    onTap: () => _onLevelChanged(1),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Level 2',
                    isSelected: _selectedLevel == 2,
                    onTap: () => _onLevelChanged(2),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Level 3',
                    isSelected: _selectedLevel == 3,
                    onTap: () => _onLevelChanged(3),
                  ),
                ],
              ),
            ),
          ),

          // Results count
          if (_filteredCourses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredCourses.length} course${_filteredCourses.length == 1 ? '' : 's'} found',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ),

          // Courses List/Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAllCourses,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredCourses.isEmpty
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
                                  _selectedLevel != null
                                      ? 'Try a different level or search term'
                                      : 'Try adjusting your search or filters',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_selectedLevel != null || _searchQuery.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: TextButton(
                                      onPressed: () {
                                        _selectedLevel = null;
                                        _searchController.clear();
                                      },
                                      child: const Text('Clear Filters'),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAllCourses,
                            child: _isGridView
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.75,
                                    ),
                                    itemCount: _filteredCourses.length,
                                    itemBuilder: (context, index) {
                                      final course = _filteredCourses[index];
                                      return CourseCard(
                                        course: course,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => CourseDetailScreen(courseId: course.id),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredCourses.length,
                                    itemBuilder: (context, index) {
                                      final course = _filteredCourses[index];
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}

