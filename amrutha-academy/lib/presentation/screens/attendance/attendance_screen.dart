import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/attendance_model.dart';
import '../../../core/config/di_config.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String? courseId;

  const AttendanceScreen({super.key, this.courseId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _apiService = GetIt.instance<ApiService>();
  List<AttendanceModel> _attendanceList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = widget.courseId != null
          ? '/attendance/my-attendance?courseId=${widget.courseId}'
          : '/attendance/my-attendance';

      final response = await _apiService.get<List<AttendanceModel>>(
        url,
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _attendanceList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load attendance';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  int get presentCount => _attendanceList.where((a) => a.status == 'present').length;
  int get totalCount => _attendanceList.length;
  double get attendancePercentage => totalCount > 0 ? (presentCount / totalCount * 100) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
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
                        onPressed: _loadAttendance,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _attendanceList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No attendance records',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAttendance,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Attendance Summary',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem('Total', totalCount.toString(), Icons.event),
                                        _buildStatItem('Present', presentCount.toString(), Icons.check_circle),
                                        _buildStatItem(
                                          'Percentage',
                                          '${attendancePercentage.toStringAsFixed(1)}%',
                                          Icons.percent,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearProgressIndicator(
                                      value: attendancePercentage / 100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        attendancePercentage >= 75
                                            ? Colors.green
                                            : attendancePercentage >= 50
                                                ? Colors.orange
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Attendance Details',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _attendanceList.length,
                              itemBuilder: (context, index) {
                                final attendance = _attendanceList[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: attendance.status == 'present'
                                          ? Colors.green
                                          : Colors.red,
                                      child: Icon(
                                        attendance.status == 'present'
                                            ? Icons.check
                                            : Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      _formatDate(attendance.markedAt),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ${attendance.status.toUpperCase()}'),
                                        if (attendance.joinedAt != null)
                                          Text(
                                            'Joined: ${_formatTime(attendance.joinedAt!)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Chip(
                                      label: Text(
                                        attendance.status.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: attendance.status == 'present'
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}

