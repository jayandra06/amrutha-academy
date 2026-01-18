import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../services/notification_service.dart';
import '../../widgets/app_drawer.dart';

class UpcomingClassesScreen extends StatefulWidget {
  final String? courseId;

  const UpcomingClassesScreen({super.key, this.courseId});

  @override
  State<UpcomingClassesScreen> createState() => _UpcomingClassesScreenState();
}

class _UpcomingClassesScreenState extends State<UpcomingClassesScreen> {
  final _scheduleRepository = ScheduleRepository();
  List<ScheduleModel> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await _scheduleRepository.getUpcomingSchedules(
        courseId: widget.courseId,
      );

      if (!mounted) return;
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinClass(ScheduleModel schedule) async {
    if (schedule.meetingLink == null || schedule.meetingLink!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting link not available')),
      );
      return;
    }

    // Navigate to Jitsi Meet webview
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JitsiMeetScreen(meetingUrl: schedule.meetingLink!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Upcoming Classes'),
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
                        onPressed: _loadSchedules,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _schedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No upcoming classes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSchedules,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = _schedules[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.video_call,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                              trailing: schedule.isUpcoming || schedule.isOngoing
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.notifications),
                                          onPressed: () {
                                            // Schedule notification
                                            NotificationService().scheduleClassReminder(
                                              title: 'Class Reminder',
                                              body: 'You have a class starting soon',
                                              scheduledTime: schedule.startTime,
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Reminder set for 15 minutes before class'),
                                              ),
                                            );
                                          },
                                          tooltip: 'Set Reminder',
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _joinClass(schedule),
                                          child: const Text('Join'),
                                        ),
                                      ],
                                    )
                                  : null,
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

class JitsiMeetScreen extends StatefulWidget {
  final String meetingUrl;

  const JitsiMeetScreen({super.key, required this.meetingUrl});

  @override
  State<JitsiMeetScreen> createState() => _JitsiMeetScreenState();
}

class _JitsiMeetScreenState extends State<JitsiMeetScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.meetingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Class'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

