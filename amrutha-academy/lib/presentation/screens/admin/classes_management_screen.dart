import 'package:flutter/material.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../widgets/app_drawer.dart';
import 'create_course_screen.dart';

class ClassesManagementScreen extends StatefulWidget {
  const ClassesManagementScreen({super.key});

  @override
  State<ClassesManagementScreen> createState() => _ClassesManagementScreenState();
}

class _ClassesManagementScreenState extends State<ClassesManagementScreen> {
  final _courseRepository = CourseRepository();
  final _searchController = TextEditingController();
  
  List<CourseModel> _allCourses = [];
  List<CourseModel> _filteredCourses = [];
  
  bool _isLoading = true;
  bool _showHistory = false;
  String? _errorMessage;
  String? _selectedLevel;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
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

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courses = await _courseRepository.getAllCourses();
      
      print('📚 Loaded ${courses.length} courses from repository');
      print('   All courses: ${courses.map((c) => c.title).join(", ")}');
      
      setState(() {
        _allCourses = courses;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      print('❌ Error loading courses: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<CourseModel> filtered = List.from(_allCourses);

    print('🔍 Applying filters on ${_allCourses.length} courses');
    print('   Show history: $_showHistory');

    // Filter by active/completed
    if (_showHistory) {
      filtered = filtered.where((course) => !course.isActive).toList();
      print('   History filter: ${filtered.length} courses');
    } else {
      // Show active courses (endDate in the future)
      filtered = filtered.where((course) {
        try {
          final isActive = course.isActive;
          print('   Course "${course.title}": isActive=$isActive, endDate=${course.endDate}');
          return isActive;
        } catch (e) {
          print('   ⚠️ Error checking isActive for "${course.title}": $e');
          // If there's an error, include it in active courses to show it
          return true;
        }
      }).toList();
      print('   Active filter result: ${filtered.length} courses');
      
      // DEBUG: If no courses after filtering, show all to debug
      if (filtered.isEmpty && _allCourses.isNotEmpty) {
        print('   ⚠️ WARNING: All courses filtered out! Showing all courses for debugging.');
        print('   All courses endDates: ${_allCourses.map((c) => "${c.title}: ${c.endDate}").join(", ")}');
        filtered = List.from(_allCourses); // Show all for now
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((course) {
        final titleMatch = course.title.toLowerCase().contains(_searchQuery);
        final descMatch = course.description.toLowerCase().contains(_searchQuery);
        return titleMatch || descMatch;
      }).toList();
    }

    // Apply level filter
    if (_selectedLevel != null) {
      filtered = filtered.where((course) => course.level.toString() == _selectedLevel).toList();
    }

    print('✅ Final filtered courses: ${filtered.length}');
    
    setState(() {
      _filteredCourses = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(_showHistory ? 'Course History' : 'Courses Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
              );
              if (result == true) {
                _loadCourses();
              }
            },
            tooltip: 'Create Course',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showHistory = false;
                      });
                      _applyFilters();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !_showHistory
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Active Courses',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_showHistory
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight: !_showHistory ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showHistory = true;
                      });
                      _applyFilters();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _showHistory
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Course History',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _showHistory
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight: _showHistory ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by course name',
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
                DropdownButtonFormField<String>(
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
                  '${_filteredCourses.length} course${_filteredCourses.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_selectedLevel != null || _searchQuery.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedLevel = null;
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
          // Courses list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCourses,
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
                      : _filteredCourses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.class_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty || _selectedLevel != null
                                        ? 'No courses match the filters'
                                        : _showHistory
                                            ? 'No completed courses'
                                            : 'No active courses',
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
                                        'Course Name',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Level',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Price',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Duration',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Trainer',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Status',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  rows: _filteredCourses.map((course) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            course.title,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          onTap: () {
                                            // TODO: Navigate to course details
                                          },
                                        ),
                                        DataCell(
                                          Text('Level ${course.level}'),
                                        ),
                                        DataCell(
                                          Text('₹${course.price.toStringAsFixed(2)}'),
                                        ),
                                        DataCell(
                                          Text('${course.duration} days'),
                                        ),
                                        DataCell(
                                          Text(course.trainerName ?? '-'),
                                        ),
                                        DataCell(
                                          course.isActive
                                              ? Chip(
                                                  label: const Text('Active'),
                                                  backgroundColor: Colors.green[100],
                                                  labelStyle: const TextStyle(fontSize: 12),
                                                  visualDensity: VisualDensity.compact,
                                                )
                                              : Chip(
                                                  label: const Text('Completed'),
                                                  backgroundColor: Colors.grey[300],
                                                  labelStyle: const TextStyle(fontSize: 12),
                                                  visualDensity: VisualDensity.compact,
                                                ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
