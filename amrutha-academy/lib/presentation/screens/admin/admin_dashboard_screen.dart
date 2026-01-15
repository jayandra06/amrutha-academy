import 'package:flutter/material.dart';
import 'create_course_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            'Create Course',
            Icons.add_circle_outline,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'View Courses',
            Icons.school,
            Colors.green,
            () {
              // Navigate to courses list
            },
          ),
          _buildDashboardCard(
            context,
            'Manage Trainers',
            Icons.person,
            Colors.orange,
            () {
              // Navigate to trainers
            },
          ),
          _buildDashboardCard(
            context,
            'View Reports',
            Icons.assessment,
            Colors.purple,
            () {
              // Navigate to reports
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




