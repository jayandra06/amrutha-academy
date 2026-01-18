import 'dart:async';
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
  String? _lastLoadedUserId; // Track which user we loaded
  StreamSubscription? _userStreamSubscription; // Listen to Firestore changes

  @override
  void initState() {
    super.initState();
    _setupUserListener();
    
    // Listen to auth state changes to refresh when user logs in/out
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        _lastLoadedUserId = null; // Reset to force reload
        _setupUserListener(); // Re-setup listener for new user
      }
    });
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }

  void _setupUserListener() {
    // Cancel existing subscription
    _userStreamSubscription?.cancel();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
      return;
    }

    // Check if Firestore is initialized
    if (FirebaseConfig.firestore == null) {
      print('❌ AppDrawer - Firestore is not initialized!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // First, do a quick one-time fetch for immediate display
    _loadUserProfile(forceRefresh: true).then((_) {
      // Then set up real-time listener for updates
      if (!mounted) return;
      
      _userStreamSubscription = FirebaseConfig.firestore!
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
        (docSnapshot) {
          if (!mounted) return;
          
          if (docSnapshot.exists) {
            final userData = docSnapshot.data()!;
            
            // Only log if role changed (to reduce spam)
            if (_currentUser?.role != userData['role']) {
              print('🔍 AppDrawer - Role updated: ${_currentUser?.role} → ${userData['role']}');
            }
            
            final loadedUser = UserModel.fromJson({
              'id': user.uid,
              ...userData,
            });
            
            setState(() {
              _currentUser = loadedUser;
              _lastLoadedUserId = user.uid;
              _isLoading = false;
            });
          } else {
            // Document doesn't exist - try to create it (only once to avoid loops)
            if (_currentUser == null) {
              print('⚠️ AppDrawer Stream - User document not found, will be created by _loadUserProfile');
              // Don't set state here, let _loadUserProfile handle it
            }
          }
        },
        onError: (error) {
          print('❌ AppDrawer - Stream error: $error');
          // Don't update state on stream error, keep existing data
        },
      );
    });
  }

  Future<void> _loadUserProfile({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    final user = FirebaseAuth.instance.currentUser;
    
    // Skip if we already loaded this user's data (unless forced)
    if (!forceRefresh && user != null && _lastLoadedUserId == user.uid && _currentUser != null) {
      print('⏭️ AppDrawer - Skipping reload, already have user data for ${user.uid}');
      return;
    }
    
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (user != null) {
        // Check if Firestore is initialized
        if (FirebaseConfig.firestore == null) {
          print('❌ AppDrawer - Firestore is not initialized!');
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          return;
        }

        print('🔍 AppDrawer - Fetching user document from Firestore...');
        print('   Collection: users');
        print('   Document ID: ${user.uid}');
        
        final userDoc = await FirebaseConfig.firestore!
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Firestore query timed out after 10 seconds');
              },
            );
            
        print('🔍 AppDrawer - Firestore query completed');
        print('   Document exists: ${userDoc.exists}');
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          
          // Debug logging
          print('🔍 AppDrawer - User data loaded:');
          print('   User ID: ${user.uid}');
          print('   Role from Firestore: ${userData['role']}');
          print('   Role type: ${userData['role'].runtimeType}');
          print('   Full user data keys: ${userData.keys.toList()}');
          
          final loadedUser = UserModel.fromJson({
            'id': user.uid,
            ...userData,
          });
          
          print('🔍 AppDrawer - Parsed user model:');
          print('   Parsed Role: ${loadedUser.role}');
          print('   isAdmin: ${loadedUser.isAdmin}');
          print('   isTrainer: ${loadedUser.isTrainer}');
          
          if (!mounted) return;
          setState(() {
            _currentUser = loadedUser;
            _lastLoadedUserId = user.uid;
            _isLoading = false;
          });
          
          print('✅ AppDrawer - User profile loaded successfully');
        } else {
          print('⚠️ AppDrawer - User document not found in Firestore for UID: ${user.uid}');
          print('   Attempting to create user document as fallback...');
          
          // Fallback: Create user document if it doesn't exist
          try {
            final phoneNumber = user.phoneNumber ?? '';
            final userData = {
              'phoneNumber': phoneNumber,
              'fullName': '',
              'email': user.email ?? '',
              'avatar': '',
              'bio': '',
              'birthday': '',
              'location': '',
              'role': 'student', // Default role
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            };
            
            await FirebaseConfig.firestore!
                .collection('users')
                .doc(user.uid)
                .set(userData);
            
            print('✅ AppDrawer - Created user document with default role: student');
            
            // Reload the user data
            final createdUser = UserModel.fromJson({
              'id': user.uid,
              ...userData,
            });
            
            if (!mounted) return;
            setState(() {
              _currentUser = createdUser;
              _lastLoadedUserId = user.uid;
              _isLoading = false;
            });
          } catch (createError) {
            print('❌ AppDrawer - Failed to create user document: $createError');
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              // Keep _currentUser as null so it shows student menu as fallback
            });
          }
        }
      } else {
        print('⚠️ AppDrawer - No current user in Firebase Auth');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ AppDrawer - Error loading user profile: $e');
      print('   Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Keep _currentUser as null on error - will show student menu as fallback
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure listener is set up if user changed (but only once)
    final currentAuthUser = FirebaseAuth.instance.currentUser;
    if (currentAuthUser != null && _lastLoadedUserId != currentAuthUser.uid && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _lastLoadedUserId != currentAuthUser.uid) {
          _setupUserListener();
        }
      });
    }

    final user = FirebaseAuth.instance.currentUser;
    final isTrainer = _currentUser?.isTrainer ?? false;
    final isAdmin = _currentUser?.isAdmin ?? false;
    
    // Only log once when user data changes (not on every build)
    // This prevents log spam

    // Show loading state (with timeout to prevent infinite loading)
    if (_isLoading) {
      // Set a maximum loading time - if it takes too long, show error
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isLoading) {
          print('⚠️ AppDrawer - Loading timeout, showing fallback menu');
          setState(() {
            _isLoading = false;
          });
        }
      });
      
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Loading role...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Drawer(
      // Use a key based on user ID to force rebuild when user changes
      key: ValueKey('drawer_${FirebaseAuth.instance.currentUser?.uid ?? 'no_user'}'),
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
                    (_currentUser?.fullName.isNotEmpty ?? false)
                        ? _currentUser!.fullName[0].toUpperCase()
                        : (user != null && user.displayName != null && user.displayName!.isNotEmpty)
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
                  _currentUser?.fullName ?? user?.displayName ?? 'User',
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
                // Debug: Show role in drawer header
                Text(
                  'Role: ${_currentUser?.role ?? "Loading..."}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                // Show refresh button for debugging
                if (_currentUser != null)
                  TextButton.icon(
                    onPressed: () {
                      _setupUserListener();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

