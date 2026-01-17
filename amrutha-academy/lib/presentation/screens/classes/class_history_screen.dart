import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/schedule_model.dart';
import '../../../core/config/di_config.dart';
import '../../widgets/app_drawer.dart';
import 'package:get_it/get_it.dart';

class ClassHistoryScreen extends StatefulWidget {
  const ClassHistoryScreen({super.key});

  @override
  State<ClassHistoryScreen> createState() => _ClassHistoryScreenState();
}

class _ClassHistoryScreenState extends State<ClassHistoryScreen> {
  final _apiService = GetIt.instance<ApiService>();
  List<ScheduleModel> _pastClasses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPastClasses();
  }

  Future<void> _loadPastClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all schedules and filter past ones
      final response = await _apiService.get<List<ScheduleModel>>(
        '/schedules/upcoming',
        fromJson: (json) {
          if (json is List) {
            return (json as List)
                .map((item) => ScheduleModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );

      if (response.isSuccess && response.data != null) {
        final now = DateTime.now();
        setState(() {
          _pastClasses = response.data!
              .where((schedule) => schedule.endTime.isBefore(now))
              .toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load class history';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Class History'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPastClasses,
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
                          onPressed: _loadPastClasses,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _pastClasses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No class history',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your completed classes will appear here',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pastClasses.length,
                        itemBuilder: (context, index) {
                          final schedule = _pastClasses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.video_library,
                                  color: Colors.grey[700],
                                ),
                              ),
                              title: Text(
                                _formatDateTime(schedule.startTime),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Duration: ${_formatDuration(schedule.startTime, schedule.endTime)}'),
                                  Text('Status: ${schedule.status}'),
                                ],
                              ),
                              trailing: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

