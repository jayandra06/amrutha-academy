import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class KitItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool inStock;
  final int stockQuantity;

  KitItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.inStock,
    required this.stockQuantity,
  });
}

class KitManagementScreen extends StatefulWidget {
  const KitManagementScreen({super.key});

  @override
  State<KitManagementScreen> createState() => _KitManagementScreenState();
}

class _KitManagementScreenState extends State<KitManagementScreen> {
  List<KitItem> _kits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKits();
  }

  Future<void> _loadKits() async {
    // TODO: Load kits from API/Firebase when available
    // For now, show sample data
    setState(() {
      _kits = [
        KitItem(
          id: '1',
          name: 'Starter Kit',
          description: 'Essential materials for beginners',
          price: 999.0,
          inStock: true,
          stockQuantity: 50,
        ),
        KitItem(
          id: '2',
          name: 'Advanced Kit',
          description: 'Complete set for advanced learners',
          price: 1999.0,
          inStock: true,
          stockQuantity: 30,
        ),
        KitItem(
          id: '3',
          name: 'Professional Kit',
          description: 'Professional grade materials',
          price: 2999.0,
          inStock: false,
          stockQuantity: 0,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Kit Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Show add kit dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add kit functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No kits available',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _kits.length,
                  itemBuilder: (context, index) {
                    final kit = _kits[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          child: Icon(
                            Icons.shopping_bag,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        title: Text(
                          kit.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kit.description),
                            const SizedBox(height: 4),
                            Text(
                              'Price: ₹${kit.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              'Stock: ${kit.stockQuantity} units',
                              style: TextStyle(
                                color: kit.inStock ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Edit kit
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit kit functionality coming soon')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () {
                                // TODO: Delete kit
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Kit'),
                                    content: Text('Are you sure you want to delete ${kit.name}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Delete functionality coming soon')),
                                          );
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}

