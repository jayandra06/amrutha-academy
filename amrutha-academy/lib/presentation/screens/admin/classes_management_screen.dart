import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../widgets/app_drawer.dart';
import 'package:get_it/get_it.dart';
import 'create_course_screen.dart';

class ClassesManagementScreen extends StatefulWidget {
  const ClassesManagementScreen({super.key});

  @override
  State<ClassesManagementScreen> createState() => _ClassesManagementScreenState();
}

class _ClassesManagementScreenState extends State<ClassesManagementScreen> {
  final _apiService = GetIt.instance<ApiService>();
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
      
      setState(() {
        _allCourses = courses;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<CourseModel> filtered = List.from(_allCourses);

    // Filter by active/completed
    if (_showHistory) {
      filtered = filtered.where((course) => !course.isActive).toList();
    } else {
      filtered = filtered.where((course) => course.isActive).toList();
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

    setState(() {
      _filteredCourses = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(_showHistory ? 'Course History' : 'Classes Management'),
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
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredCourses.length,
                              itemBuilder: (context, index) {
                                final course = _filteredCourses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: course.isActive
                                          ? Theme.of(context).colorScheme.primaryContainer
                                          : Colors.grey[300],
                                      child: Icon(
                                        course.isActive ? Icons.school : Icons.history,
                                        color: course.isActive
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    title: Text(
                                      course.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Level ${course.level}'),
                                        Text('Duration: ${course.duration} days'),
                                        Text('Fees: ₹${course.price.toStringAsFixed(2)}'),
                                        Text(
                                          'Start: ${_formatDate(course.startDate)} - End: ${_formatDate(course.endDate)}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        if (course.trainerName != null)
                                          Text(
                                            'Trainer: ${course.trainerName}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        if (!course.isActive)
                                          Chip(
                                            label: const Text('Completed'),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    isThreeLine: true,
                                    onTap: () {
                                      // TODO: Navigate to course details
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
