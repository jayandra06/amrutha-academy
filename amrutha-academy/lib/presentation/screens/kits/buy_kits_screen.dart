import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class KitModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool inStock;

  KitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.inStock,
  });
}

class BuyKitsScreen extends StatefulWidget {
  const BuyKitsScreen({super.key});

  @override
  State<BuyKitsScreen> createState() => _BuyKitsScreenState();
}

class _BuyKitsScreenState extends State<BuyKitsScreen> {
  List<KitModel> _kits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKits();
  }

  Future<void> _loadKits() async {
    // TODO: Load kits from API when available
    // For now, show sample data
    setState(() {
      _kits = [
        KitModel(
          id: '1',
          name: 'Starter Kit',
          description: 'Essential materials for beginners',
          price: 999.0,
          imageUrl: '',
          inStock: true,
        ),
        KitModel(
          id: '2',
          name: 'Advanced Kit',
          description: 'Complete set for advanced learners',
          price: 1999.0,
          imageUrl: '',
          inStock: true,
        ),
        KitModel(
          id: '3',
          name: 'Professional Kit',
          description: 'Professional grade materials',
          price: 2999.0,
          imageUrl: '',
          inStock: false,
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
        title: const Text('Buy Kits'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
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
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _kits.length,
                  itemBuilder: (context, index) {
                    final kit = _kits[index];
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                              child: kit.imageUrl.isEmpty
                                  ? Icon(
                                      Icons.shopping_bag,
                                      size: 64,
                                      color: Colors.grey[400],
                                    )
                                  : Image.network(
                                      kit.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kit.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  kit.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${kit.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    ),
                                    if (!kit.inStock)
                                      Chip(
                                        label: const Text(
                                          'Out of Stock',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: Colors.red[100],
                                        labelStyle: TextStyle(color: Colors.red[900]),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: kit.inStock
                                        ? () {
                                            // TODO: Add to cart or navigate to kit detail
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${kit.name} added to cart'),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: const Text('Add to Cart'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

