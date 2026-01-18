import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/repositories/enrollment_repository.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/course_model.dart';
import '../../../core/config/di_config.dart';
import '../../widgets/app_drawer.dart';
import 'package:get_it/get_it.dart';

class TransactionModel {
  final String id;
  final String orderId;
  final String paymentId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? courseId;
  final String? courseTitle;

  TransactionModel({
    required this.id,
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.courseId,
    this.courseTitle,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      paymentId: json['paymentId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      courseId: json['courseId'],
      courseTitle: json['courseTitle'],
    );
  }
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _enrollmentRepository = EnrollmentRepository();
  final _courseRepository = CourseRepository();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get enrollments which contain payment information
      final enrollments = await _enrollmentRepository.getMyEnrollments();
      
      // Convert enrollments to transactions
      final transactions = <TransactionModel>[];
      for (final enrollment in enrollments) {
        if (!mounted) return;
        
        // Only show enrollments with payment information
        if (enrollment.paymentId != null && enrollment.paymentId!.isNotEmpty) {
          // Get course details for the transaction
          CourseModel? course;
          try {
            course = await _courseRepository.getCourseById(enrollment.courseId);
          } catch (e) {
            print('Error fetching course for transaction: $e');
          }

          transactions.add(TransactionModel(
            id: enrollment.id,
            orderId: enrollment.paymentId ?? enrollment.id,
            paymentId: enrollment.paymentId ?? '',
            amount: course?.price ?? 0.0,
            status: enrollment.paymentStatus == 'completed' 
                ? 'completed' 
                : enrollment.paymentStatus == 'failed' 
                    ? 'failed' 
                    : 'pending',
            createdAt: enrollment.enrolledAt,
            courseId: enrollment.courseId,
            courseTitle: course?.title ?? 'Course',
          ));
        }
      }

      // Sort by date (newest first)
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
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
                          onPressed: _loadTransactions,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your payment history will appear here',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(transaction.status).withOpacity(0.2),
                                child: Icon(
                                  _getStatusIcon(transaction.status),
                                  color: _getStatusColor(transaction.status),
                                ),
                              ),
                              title: Text(
                                transaction.courseTitle ?? 'Payment',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order ID: ${transaction.orderId}'),
                                  Text(
                                    _formatDate(transaction.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${transaction.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      transaction.status.toUpperCase(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: _getStatusColor(transaction.status).withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: _getStatusColor(transaction.status),
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return Colors.green;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return Icons.check_circle;
      case 'failed':
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

