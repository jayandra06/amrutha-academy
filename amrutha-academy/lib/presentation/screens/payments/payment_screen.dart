import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../data/models/course_model.dart';

class PaymentScreen extends StatefulWidget {
  final CourseModel course;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.course,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _createOrderAndPay() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // TODO: Payment integration requires backend for order creation and verification
      // For now, using direct payment without order creation
      // In production, implement Firebase Cloud Functions or keep backend for payment processing
      
      // Placeholder: Direct payment without order creation
      // This is a simplified version - production should use backend order creation
      final keyId = 'rzp_test_1DP5mmOlF5G5ag'; // Replace with your Razorpay key from Firebase/config
      final amount = (widget.course.price * 100).toInt(); // Amount in paise

      // Open Razorpay checkout
      final options = {
        'key': keyId,
        'amount': amount,
        'name': 'Amrutha Academy',
        'description': widget.course.title,
        'prefill': {
          'contact': '',
          'email': '',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initiate payment: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // TODO: Implement payment verification via Firebase Cloud Functions
      // For now, directly call success callback
      // In production, verify payment signature before proceeding
      
      if (!mounted) return;
      widget.onPaymentSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Payment verification error: $e';
        _isProcessing = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _errorMessage = response.message ?? 'Payment failed';
      _isProcessing = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.payment,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Enroll in Course',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Level ${widget.course.level}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '₹${widget.course.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _isProcessing ? null : _createOrderAndPay,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

