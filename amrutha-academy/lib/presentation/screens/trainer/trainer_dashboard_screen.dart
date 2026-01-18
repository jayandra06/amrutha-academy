import 'package:flutter/material.dart';
import '../schedules/create_schedule_screen.dart';
import '../classes/upcoming_classes_screen.dart';
import '../classes/class_history_screen.dart';
import '../attendance/attendance_screen.dart';
import '../../widgets/app_drawer.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            'My Classes',
            Icons.class_,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpcomingClassesScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Create Schedule',
            Icons.event,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateScheduleScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Mark Attendance',
            Icons.check_circle,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Class History',
            Icons.history,
            Colors.purple,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClassHistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

