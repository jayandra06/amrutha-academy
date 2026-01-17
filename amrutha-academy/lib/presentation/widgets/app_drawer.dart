import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/firebase_config.dart';
import '../../data/models/user_model.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/classes/upcoming_classes_screen.dart';
import '../screens/classes/class_history_screen.dart';
import '../screens/kits/buy_kits_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/schedules/create_schedule_screen.dart';
import '../screens/admin/students_management_screen.dart';
import '../screens/admin/trainers_management_screen.dart';
import '../screens/admin/classes_management_screen.dart';
import '../screens/admin/kit_management_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseConfig.firestore?.collection('users').doc(user.uid).get();
        if (userDoc?.exists ?? false) {
          setState(() {
            _currentUser = UserModel.fromJson({
              'id': user.uid,
              ...userDoc!.data()!,
            });
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isTrainer = _currentUser?.isTrainer ?? false;
    final isAdmin = _currentUser?.isAdmin ?? false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(
                    (user != null && user.displayName != null && user.displayName!.isNotEmpty)
                        ? user.displayName![0].toUpperCase()
                        : (user != null && user.email != null && user.email!.isNotEmpty)
                            ? user.email![0].toUpperCase()
                            : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'User',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (isAdmin) ...[
            // Admin menu items
            _buildDrawerItem(
              context,
              icon: Icons.people,
              title: 'Students',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentsManagementScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person_outline,
              title: 'Trainers',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrainersManagementScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.class_,
              title: 'Classes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClassesManagementScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.payment,
              title: 'Payments',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.inventory_2,
              title: 'Kit Management',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KitManagementScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ] else if (isTrainer) ...[
            // Trainer menu items
            _buildDrawerItem(
              context,
              icon: Icons.add_circle_outline,
              title: 'Create Class',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateScheduleScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.calendar_today,
              title: 'Upcoming Classes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpcomingClassesScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.history,
              title: 'Class History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClassHistoryScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.receipt_long,
              title: 'Payment History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.shopping_bag,
              title: 'Buy Kits',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyKitsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ] else ...[
            // Student menu items
            _buildDrawerItem(
              context,
              icon: Icons.receipt_long,
              title: 'Transactions',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.calendar_today,
              title: 'Upcoming Classes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpcomingClassesScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.history,
              title: 'Class History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClassHistoryScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.shopping_bag,
              title: 'Buy Kits',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyKitsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'Account',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.shopping_cart,
              title: 'Cart',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ],
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              Navigator.pop(context);
              
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await FirebaseAuth.instance.signOut();
                // Navigate to splash screen which will redirect to login if not authenticated
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

