import 'package:b2b_ecommerce/add_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import 'providers/cart_provider.dart';
import 'screens/cart_screen.dart';
import 'login.dart';
import 'register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final logger = Logger();
  final user = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();

      final fetchedProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'],
          'price': data['price'],
          'quantity': data['quantity'],
          'image': data['image'] ?? 'https://picsum.photos/200/300',
        };
      }).toList();

      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });

      logger.d("Fetched products: $products");
    } catch (e) {
      logger.e("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final isLoggedIn = user != null;

    if (isLoggedIn) {
      logger.d('User is logged in');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else if (value == 'register') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'login', child: Text('Login')),
              const PopupMenuItem(value: 'register', child: Text('Register')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoggedIn)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome, ${user?.email ?? 'User'}!',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          if (isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProductScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text("No products available"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    product['image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, _) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text('Price: \$${product['price']}'),
                                      Text('Qty: ${product['quantity']}'),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref
                                              .read(cartProvider.notifier)
                                              .addToCart(
                                                CartItem(
                                                  name: product['name'],
                                                  price: product['price'],
                                                ),
                                              );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "${product['name']} added to cart"),
                                          ));
                                        },
                                        child: const Text('Add to Cart'),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}