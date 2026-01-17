import 'package:flutter/material.dart';
import '../../../core/config/firebase_config.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/app_drawer.dart';

class TrainersManagementScreen extends StatefulWidget {
  const TrainersManagementScreen({super.key});

  @override
  State<TrainersManagementScreen> createState() => _TrainersManagementScreenState();
}

class _TrainersManagementScreenState extends State<TrainersManagementScreen> {
  List<UserModel> _trainers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final usersSnapshot = await FirebaseConfig.firestore
          ?.collection('users')
          .where('role', isEqualTo: 'trainer')
          .get();

      if (usersSnapshot != null) {
        final trainers = usersSnapshot.docs
            .map((doc) => UserModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();

        setState(() {
          _trainers = trainers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _trainers = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load trainers: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Trainers'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrainers,
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
                          onPressed: _loadTrainers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _trainers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No trainers found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _trainers.length,
                        itemBuilder: (context, index) {
                          final trainer = _trainers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                child: Text(
                                  trainer.fullName.isNotEmpty
                                      ? trainer.fullName[0].toUpperCase()
                                      : 'T',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(
                                trainer.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trainer.email),
                                  if (trainer.phoneNumber.isNotEmpty)
                                    Text(trainer.phoneNumber),
                                  if (trainer.bio != null && trainer.bio!.isNotEmpty)
                                    Text(
                                      trainer.bio!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

