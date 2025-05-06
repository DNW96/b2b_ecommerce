import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import 'providers/cart_provider.dart';
import 'screens/cart_screen.dart';
import 'login.dart';
import 'register.dart';
import 'package:firebase_auth/firebase_auth.dart';





class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    final List<Map<String, dynamic>> products = [
      {
        'name': 'Product 1',
        'price': 49.99,
        'quantity': 10,
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Product 2',
        'price': 89.50,
        'quantity': 5,
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Product 3',
        'price': 120.00,
        'quantity': 3,
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Product 4',
        'price': 75.25,
        'quantity': 7,
        'image': 'https://via.placeholder.com/150'
      },
    ];

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
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
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
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  child: Image.network(product['image'], fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Price: \$${product['price']}'),
                      Text('Qty: ${product['quantity']}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(
                                CartItem(
                                  name: product['name'],
                                  price: product['price'],
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("${product['name']} added to cart"),
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
    );
  }
}
