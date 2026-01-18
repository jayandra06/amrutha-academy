import 'package:flutter/material.dart';
import 'create_course_screen.dart';
import 'classes_management_screen.dart';
import 'kit_management_screen.dart';
import '../courses/course_list_screen.dart';
import 'trainers_management_screen.dart';
import 'students_management_screen.dart';
import '../transactions/transactions_screen.dart';
import '../../widgets/app_drawer.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseListScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Manage Trainers',
            Icons.person,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrainersManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Manage Students',
            Icons.people,
            Colors.teal,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentsManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Payments',
            Icons.payment,
            Colors.indigo,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Classes',
            Icons.class_,
            Colors.deepPurple,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClassesManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Kit Management',
            Icons.inventory_2,
            Colors.brown,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KitManagementScreen()),
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




