import 'package:flutter/material.dart';
import '../../../core/config/firebase_config.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../widgets/app_drawer.dart';
import 'create_trainer_screen.dart';
import 'trainer_detail_screen.dart';

class TrainersManagementScreen extends StatefulWidget {
  const TrainersManagementScreen({super.key});

  @override
  State<TrainersManagementScreen> createState() => _TrainersManagementScreenState();
}

class _TrainersManagementScreenState extends State<TrainersManagementScreen> {
  final _searchController = TextEditingController();
  final _courseRepository = CourseRepository();
  
  List<UserModel> _allTrainers = [];
  List<UserModel> _filteredTrainers = [];
  List<CourseModel> _courses = [];
  Map<String, List<CourseModel>> _trainerCourses = {};
  
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
      // Load trainers
      final usersSnapshot = await FirebaseConfig.firestore
          ?.collection('users')
          .where('role', isEqualTo: 'trainer')
          .get();

      if (usersSnapshot != null) {
        final trainers = usersSnapshot.docs
            .map((doc) => UserModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();

        // Load courses for filtering
        final courses = await _courseRepository.getAllCourses();
        
        // Map courses to trainers
        final trainerCoursesMap = <String, List<CourseModel>>{};
        for (var trainer in trainers) {
          trainerCoursesMap[trainer.id] = courses
              .where((course) => course.trainerId == trainer.id)
              .toList();
        }

        setState(() {
          _allTrainers = trainers;
          _courses = courses;
          _trainerCourses = trainerCoursesMap;
          _isLoading = false;
        });
        _applyFilters();
      } else {
        setState(() {
          _allTrainers = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load trainers: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<UserModel> filtered = List.from(_allTrainers);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((trainer) {
        final nameMatch = trainer.fullName.toLowerCase().contains(_searchQuery);
        final phoneMatch = trainer.phoneNumber.contains(_searchQuery);
        final emailMatch = trainer.email.toLowerCase().contains(_searchQuery);
        return nameMatch || phoneMatch || emailMatch;
      }).toList();
    }

    // Apply level filter
    if (_selectedLevel != null) {
      filtered = filtered.where((trainer) {
        final courses = _trainerCourses[trainer.id] ?? [];
        return courses.any((course) => course.level.toString() == _selectedLevel);
      }).toList();
    }

    // Apply course filter
    if (_selectedCourseId != null && _selectedCourseId!.isNotEmpty) {
      filtered = filtered.where((trainer) {
        final courses = _trainerCourses[trainer.id] ?? [];
        return courses.any((course) => course.id == _selectedCourseId);
      }).toList();
    }

    setState(() {
      _filteredTrainers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Trainers Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTrainerScreen()),
              );
              if (result == true) {
                _loadData();
              }
            },
            tooltip: 'Add Trainer',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredTrainers.length} trainer${_filteredTrainers.length != 1 ? 's' : ''}',
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
                      : _filteredTrainers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty || _selectedLevel != null || _selectedCourseId != null
                                        ? 'No trainers match the filters'
                                        : 'No trainers found',
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
                                  rows: _filteredTrainers.map((trainer) {
                                    final courses = _trainerCourses[trainer.id] ?? [];
                                    
                                    // Get course names (comma-separated if multiple)
                                    final courseNames = courses
                                        .map((course) => course.title)
                                        .join(', ');
                                    final courseNameDisplay = courseNames.isEmpty ? '-' : courseNames;

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            trainer.fullName.isNotEmpty ? trainer.fullName : '-',
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => TrainerDetailScreen(trainerId: trainer.id),
                                              ),
                                            );
                                          },
                                        ),
                                        DataCell(
                                          Text(
                                            trainer.phoneNumber.isNotEmpty ? trainer.phoneNumber : '-',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            trainer.email.isNotEmpty ? trainer.email : '-',
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
